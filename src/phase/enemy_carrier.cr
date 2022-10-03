require "./enemy"

module Phase
  class EnemyCarrier < Enemy
    getter initial_x : Float64
    getter target_x : Float64
    getter target_y : Float64
    getter star_bases : Array(StarBase)
    getter group_size : Int32
    getter enemy_group : EnemyGroup?
    getter? dropped_off

    Sheet = "./assets/carrier.png"
    SpriteWidth = 384
    SpriteHeight = 256
    HitRadius = 128
    MaxHealth = 1000

    # carrier drop off
    RotationSpeed = 33
    DropOffDistanceThreshold = 10
    DropOffMoveSpeed = 300
    DroppedOffMoveSpeed = 777
    DroppedOffTargetDistance = 9000

    def initialize(x, y, target_x, target_y, star_bases, group_size = 3)
      super(x, y)

      @initial_x = x
      @target_x = target_x
      @target_y = target_y
      @star_bases = star_bases
      @group_size = group_size
      @enemy_group = nil
      @dropped_off = false
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
      super(frame_time)

      if distance(target_x, target_y).abs > DropOffDistanceThreshold
        rotate_to_target(frame_time)
        move_forward(move_speed * frame_time)
      elsif dropped_off?
        @remove = true
      elsif !facing?(drop_off_target_rotation)
        rotate_towards(drop_off_target_rotation, RotationSpeed * frame_time)
      else
        drop_off_enemies
      end
    end

    def move_speed
      dropped_off? ? DroppedOffMoveSpeed : DropOffMoveSpeed
    end

    def drop_off_target_rotation
      initial_x <= x ? 0 : 180
    end

    def rotate_to_target(frame_time)
      target_rotation = rotation_to(target_x, target_y)

      rotate_towards(target_rotation, RotationSpeed * frame_time) unless facing?(target_rotation)
    end

    def drop_off_enemies
      enemies = [] of EnemyShip

      mid_x = x
      mid_y = y
      angle = 360 / group_size
      init_angle = angle / 2
      distance = EnemyShip.hit_radius * 2.1

      group_size.times do |index|
        e_angle = init_angle + angle * index
        theta = e_angle * Math::PI / 180
        e_x = mid_x + distance * Math.cos(theta)
        e_y = mid_y + distance * Math.sin(theta)

        enemies << EnemyShip.new(e_x, e_y)
      end

      @enemy_group = EnemyGroup.new(star_bases: star_bases, enemies: enemies)
    end

    def finish_drop_off
      @enemy_group = nil
      @dropped_off = true
      @target_x = x + (initial_x <= x ? DroppedOffTargetDistance : -DroppedOffTargetDistance)
      @target_y = y
    end
  end
end
