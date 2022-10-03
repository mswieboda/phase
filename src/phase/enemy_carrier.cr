require "./enemy"

module Phase
  class EnemyCarrier < Enemy
    getter initial_x : Float64
    getter target_x : Float64
    getter target_y : Float64
    getter star_bases : Array(StarBase)
    getter enemy_group : EnemyGroup?
    getter drop_off_timer : Timer
    getter drop_off_targets : Array(NamedTuple(x: Int32, y: Int32))

    Sheet = "./assets/carrier.png"
    SpriteWidth = 384
    SpriteHeight = 256
    HitRadius = 128
    MaxHealth = 1500

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
    ScoreValue = 50
    MinGroupSize = 2
    MaxGroupSize = 6

    def initialize(x, y, star_bases, drop_off_targets)
      super(x, y)

      @initial_x = x
      @target_x = 0
      @target_y = 0
      @star_bases = star_bases
      @drop_off_targets = drop_off_targets
      @enemy_group = nil
      @drop_off_timer = Timer.new(DropOffWaitDuration)

      new_target
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

    def self.score_value
      ScoreValue
    end

    def update(frame_time, objs : Array(HealthObj))
      super(frame_time, objs)

      distance = distance(target_x, target_y).abs

      if distance > DropOffDistanceThreshold
        rotation_speed = distance < FastRotateDistanceThreshold ? CloseRotationSpeed : RotationSpeed

        rotate_to_target(rotation_speed * frame_time)
        move_forward(MoveSpeed * frame_time, objs)
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

      group_size = rand(MaxGroupSize - MinGroupSize) + MinGroupSize

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

    def move_forward(speed, objs : Array(HealthObj))
      theta = rotation * Math::PI / 180
      dx = speed * Math.cos(theta)
      dy = speed * Math.sin(theta)

      move(dx, dy)

      objs.each do |obj|
        next if obj.is_a?(Enemy)
        next if obj.is_a?(Asteroid)

        if hit?(obj.hit_circle)
          move(-dx, -dy)
          obj.bump(dx, dy, self, objs)
        end
      end
    end

    def bump(dx, dy, bumped_by, objs)
      bumped_by.move(-dx, -dy) unless bumped_by.is_a?(Enemy)
    end

    def finish_drop_off
      @enemy_group = nil

      new_target
    end

    def next_dropoff
      drop_off_target = drop_off_targets[3 - star_bases.size]

      @target_x = drop_off_target[:x].to_f64
      @target_y = drop_off_target[:y].to_f64
    end

    def new_target
      @initial_x = x

      # new drop off position
      distance = rand(MaxNewDropOffDistance) + MinNewDropOffDistance
      theta = rand(Math::PI / 180 * 360)

      @target_x = x + distance * Math.cos(theta)
      @target_y = y + distance * Math.sin(theta)
    end
  end
end
