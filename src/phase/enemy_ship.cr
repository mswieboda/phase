require "./enemy"
require "./star_base"

module Phase
  class EnemyShip < Enemy
    getter star_base_target : StarBase

    Sheet = "./assets/enemy.png"
    RotationSpeed = 100
    TargetFacingThreshold = 3
    TargetDistanceThreshold = 500
    TargetMoveSpeed = 333

    def initialize(x, y, star_base : StarBase)
      super(x, y)

      @star_base_target = star_base
    end

    def self.sheet
      Sheet
    end

    # def update(frame_time, star_bases : Array(StarBase))
    #   super(frame_time)

    #   target_next_star_base(star_bases)

    #   update_movement(frame_time)
    # end

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

      unless facing?(target_rotation)
        sign = target_rotation >= 0 ? 1 : -1
        amount = sign * RotationSpeed * frame_time

        rotate(amount)
      end
    end

    def facing?(target_rotation)
      (target_rotation - rotation).abs < TargetFacingThreshold
    end

    def move_to_target(frame_time)
      target_distance = distance(star_base_target)

      unless target_distance.abs < TargetDistanceThreshold
        move_forward(TargetMoveSpeed * frame_time)
      end
    end

    def move_forward(speed)
      theta = rotation * Math::PI / 180
      dx = speed * Math.cos(theta)
      dy = speed * Math.sin(theta)

      @x += dx
      @y += dy
    end

    def rotate(amount)
      @rotation += amount
    end
  end
end
