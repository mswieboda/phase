require "./enemy"
require "./star_base"

module Phase
  class EnemyGroup
    getter rotation : Float32
    getter star_base_target : StarBase
    getter enemies : Array(EnemyShip)

    RotationSpeed = 100
    FacingRotationThreshold = 0.1_f32
    TargetDistanceThreshold = 500
    TargetMoveSpeed = 333

    def initialize(star_base : StarBase, enemies = [] of EnemyShip)
      @rotation = 0
      @star_base_target = star_base
      @enemies = enemies
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

    def update(frame_time, star_bases : Array(StarBase))
      enemies.each(&.update(frame_time))

      target_next_star_base(star_bases)

      update_movement(frame_time)
    end

    def target_next_star_base(star_bases : Array(StarBase))
      if star_base_target.remove?
        star_base_target = star_bases.first
      end
    end

    def update_movement(frame_time)
      rotate_to_target(frame_time)
      move_to_target(frame_time)
    end

    def rotate_to_target(frame_time)
      target_rotation = rotation_to(star_base_target)

      rotate_towards(target_rotation, RotationSpeed * frame_time) unless facing?(target_rotation)
    end

    def facing?(target_rotation)
      (target_rotation - rotation).abs < FacingRotationThreshold
    end

    def move_to_target(frame_time)
      target_distance = distance(star_base_target)

      unless target_distance.abs < TargetDistanceThreshold
        move_forward(TargetMoveSpeed * frame_time)
      end
    end

    def move_forward(speed)
      enemies.each(&.move_forward(speed))
    end

    def rotate(amount)
      @rotation += amount
      enemies.each(&.rotate(amount))
    end

    def rotate_towards(target_rotation, rotation_speed)
      sign = target_rotation >= rotation ? 1 : -1
      amount = sign * rotation_speed

      if (sign > 0 && rotation + amount > target_rotation) || (sign < 0 && rotation - amount < target_rotation)
        @rotation = target_rotation.to_f32
      else
        rotate(amount)
      end
    end

    def rotation_to(obj : HealthObj)
      obj.rotation_from(x, y)
    end

    def distance(obj : HealthObj)
      dx = x - obj.x
      dy = y - obj.y

      Math.sqrt(dx * dx + dy * dy) - obj.hit_radius
    end
  end
end
