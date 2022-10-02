require "./enemy"

module Phase
  class EnemyCarrier < Enemy
    getter drop_off_x : Float64
    getter drop_off_y : Float64

    Sheet = "./assets/carrier.png"
    SpriteWidth = 384
    SpriteHeight = 256
    HitRadius = 128
    MaxHealth = 1000
    DropOffDistanceThreshold = 10
    RotationSpeed = 33
    MoveSpeed = 100
    DropOffRotation = 0

    def initialize(x, y, drop_off_x, drop_off_y)
      super(x, y)

      @drop_off_x = drop_off_x
      @drop_off_y = drop_off_y
    end

    def self.sheet
      Sheet
    end

    def self.sprite_width
      SpriteWidth
    end

    def self.sprite_height
      SpriteHeight
    end

    def self.hit_radius
      HitRadius * Screen.scaling_factor
    end

    def self.max_health
      MaxHealth
    end

    def update(frame_time)
      super

      if distance(drop_off_x, drop_off_y).abs > DropOffDistanceThreshold
        rotate_to_target(frame_time)
        move_forward(MoveSpeed * frame_time)
      elsif !facing?(DropOffRotation)
        rotate_towards(DropOffRotation, RotationSpeed * frame_time)
      else
        # drop off enemies
      end
    end

    def rotate_to_target(frame_time)
      target_rotation = rotation_to(drop_off_x, drop_off_y)

      rotate_towards(target_rotation, RotationSpeed * frame_time) unless facing?(target_rotation)
    end
  end
end
