require "./enemy"
require "./star_base"

module Phase
  class EnemyGroup
    getter rotation : Float32
    getter star_bases : Array(StarBase)
    getter enemies : Array(EnemyShip)

    RotationSpeed = 100
    FacingRotationThreshold = 0.1_f32
    TargetDistanceThreshold = 500
    TargetMoveSpeed = 333

    def initialize(star_bases, enemies = [] of EnemyShip)
      @rotation = 0
      @star_bases = star_bases
      @enemies = enemies
    end

    def star_base_target
      star_bases.first
    end

    def mid_x
      return 0 if enemies.empty?

      points = enemies.map(&.x)

      points.min + (points.max - points.min) / 2
    end

    def mid_y
      return 0 if enemies.empty?

      points = enemies.map(&.y)

      points.min + (points.max - points.min) / 2
    end

    def x
      mid_x
    end

    def y
      mid_y
    end

    def update(frame_time, bumpables : Array(HealthObj))
      update_movement(frame_time, bumpables)
    end

    def update_movement(frame_time, bumpables : Array(HealthObj))
      rotate_to_target(frame_time)
      move_to_target(frame_time, bumpables)
    end

    def rotate_to_target(frame_time)
      target_rotation = rotation_to(star_base_target)

      rotate_towards(target_rotation, RotationSpeed * frame_time) unless facing?(target_rotation)
    end

    def facing?(target_rotation)
      (Calc.shortest_delta(target_rotation, rotation)).abs < FacingRotationThreshold
    end

    def move_to_target(frame_time, bumpables : Array(HealthObj))
      target_distance = distance(star_base_target)

      unless target_distance.abs < TargetDistanceThreshold
        move_forward(TargetMoveSpeed * frame_time, bumpables)
      end
    end

    def move_forward(speed, bumpables : Array(HealthObj))
      enemies.each(&.move_forward(speed, bumpables))
    end

    def rotate(amount)
      @rotation += amount

      if @rotation >= 360
        @rotation -= 360
      elsif @rotation < 0
        @rotation += 360
      end

      enemies.each(&.rotate(amount))
    end

    def rotate_towards(target_rotation, rotation_speed)
      delta = Calc.shortest_delta(target_rotation, rotation)
      amount = delta.sign * rotation_speed

      orig_rotation = rotation

      rotate(amount)

      if delta.sign > 0 && amount > delta
        @rotation = target_rotation.to_f32
      elsif delta.sign < 0 && amount < delta
        @rotation = target_rotation.to_f32
      end
    end

    def rotation_to(obj : HealthObj)
      obj.rotation_from(x, y)
    end

    def distance(obj : HealthObj)
      Calc.distance(x, y, obj.x, obj.y) - obj.hit_radius
    end
  end
end
