module Phase
  class Laser
    getter x : Float64
    getter y : Float64
    getter init_x : Float64
    getter init_y : Float64
    getter rotation : Float64
    getter animations
    getter? remove
    getter? from_enemy

    Speed = 1337
    Sheet = "./assets/laser.png"
    Width = 48
    Height = 16
    HitRadius = 16
    MaxDistance = 3333
    Damage = 15
    PlayerLaserColor = SF::Color::Green
    EnemyLaserColor = SF::Color::Red

    def initialize(x = 0_f32, y = 0_f32, rotation = 0, from_enemy = false)
      @x = x
      @y = y
      @init_x = x
      @init_y = y
      @rotation = rotation

      # animations
      fps = 60
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(Sheet, 0, 0, Width, Height, rotation: rotation, color: from_enemy ? EnemyLaserColor : PlayerLaserColor)

      @animations = GSF::Animations.new(:idle, idle)
      @remove = false
      @from_enemy = from_enemy
    end

    def self.hit_radius
      HitRadius
    end

    def hit_radius
      self.class.hit_radius
    end

    def distance
      dx = x - init_x
      dy = y - init_y

      Math.sqrt(dx * dx + dy * dy)
    end

    def update(frame_time, shootables : Array(HealthObj))
      animations.update(frame_time)

      update_movement(frame_time)

      check_distance
      check_shootables(shootables)
    end

    def update_movement(frame_time)
      speed = Speed * frame_time
      theta = rotation * Math::PI / 180

      @x += speed * Math.cos(theta)
      @y += speed * Math.sin(theta)
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y)
    end

    def hit_circles
      [
        Circle.new(x: x, y: y, radius: hit_radius)
      ]
    end

    def hit?(circle : Circle)
      hit_circles.any?(&.intersects?(circle))
    end

    def check_distance
      fade_remove if distance > MaxDistance
    end

    def check_shootables(shootables : Array(HealthObj))
      shootables.each do |shootable|
        if from_enemy?
          next if shootable.is_a?(Enemy)
        else
          next if shootable.is_a?(Ship)
          next if shootable.is_a?(StarBase)
          next if shootable.is_a?(BlockadeShip)
        end

        if hit?(shootable.hit_circle)
          shootable.hit(Damage)

          explode_remove
        end
      end
    end

    def fade_remove
      @remove = true
    end

    def explode_remove
      @remove = true
    end
  end
end
