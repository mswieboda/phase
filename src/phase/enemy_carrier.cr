require "./enemy"

module Phase
  class EnemyCarrier < Enemy
    getter initial_x : Float64
    getter target_x : Float64
    getter target_y : Float64
    getter star_bases : Array(StarBase)
    getter group_size : Int32
    getter enemy_group : EnemyGroup?
    getter drop_off_timer : Timer

    Sheet = "./assets/carrier.png"
    SpriteWidth = 384
    SpriteHeight = 256
    HitRadius = 128
    MaxHealth = 1000

    # carrier drop off
    RotationSpeed = 33
    MoveSpeed = 300
    DropOffDistanceThreshold = 3
    FastRotateDistanceThreshold = 750
    CloseRotationSpeed = 133
    MaxMidDistance = 128
    MinNewDropOffDistance = 300
    MaxNewDropOffDistance = 500
    DropOffWaitDuration = 3.seconds

    def initialize(x, y, target_x, target_y, star_bases, group_size = 3)
      super(x, y)

      @initial_x = x
      @target_x = target_x
      @target_y = target_y
      @star_bases = star_bases
      @group_size = group_size
      @enemy_group = nil
      @drop_off_timer = Timer.new(DropOffWaitDuration)
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
      HitRadius
    end

    def self.max_health
      MaxHealth
    end

    def update(frame_time, bumpables : Array(HealthObj))
      super(frame_time, bumpables)

      distance = distance(target_x, target_y).abs

      if distance > DropOffDistanceThreshold
        rotation_speed = distance < FastRotateDistanceThreshold ? CloseRotationSpeed : RotationSpeed

        rotate_to_target(rotation_speed * frame_time)
        move_forward(MoveSpeed * frame_time, bumpables)
      elsif !facing?(drop_off_target_rotation)
        rotate_towards(drop_off_target_rotation, RotationSpeed * frame_time)
      else
        if drop_off_timer.done?
          drop_off_enemies

          drop_off_timer.stop
        else
          drop_off_timer.start unless drop_off_timer.started?
        end
      end
    end

    def drop_off_target_rotation
      initial_x <= x ? 0 : 180
    end

    def rotate_to_target(rotation_speed)
      target_rotation = rotation_to(target_x, target_y)

      rotate_towards(target_rotation, rotation_speed) unless facing?(target_rotation)
    end

    def drop_off_enemies
      enemies = [] of EnemyShip

      # adds randomness to mid_x, mid_y
      distance = rand(MaxMidDistance)
      theta = rand(Math::PI / 180 * 360)
      mid_x = x + distance * Math.cos(theta)
      mid_y = y + distance * Math.sin(theta)

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

    def move_forward(speed, bumpables : Array(HealthObj))
      theta = rotation * Math::PI / 180
      dx = speed * Math.cos(theta)
      dy = speed * Math.sin(theta)

      move(dx, dy)

      bumpables.each do |bumpable|
        next if bumpable.is_a?(Enemy)

        if hit?(bumpable.hit_circle)
          move(-dx, -dy)
          bumpable.bump(dx, dy, self, bumpables)
        end
      end
    end

    def bump(dx, dy, bumped_by, bumpables)
      bumped_by.move(-dx, -dy) unless bumped_by.is_a?(Enemy)
    end

    def finish_drop_off
      @enemy_group = nil
      @initial_x = x

      # new drop off position
      distance = rand(MaxNewDropOffDistance) + MinNewDropOffDistance
      theta = rand(Math::PI / 180 * 360)

      @target_x = x + distance * Math.cos(theta)
      @target_y = y + distance * Math.sin(theta)
    end
  end
end
