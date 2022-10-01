module Phase
  class Laser
    getter x : Float64
    getter y : Float64
    getter init_x : Float64
    getter init_y : Float64
    getter rotation : Float64
    getter animations
    getter? remove

    Speed = 3000
    Sheet = "./assets/laser.png"
    Width = 48
    Height = 16
    HitRadius = 16
    MaxDistance = 3333

    def initialize(x = 0_f32, y = 0_f32, rotation = 0)
      @x = x
      @y = y
      @init_x = x
      @init_y = y
      @rotation = rotation

      # animations
      fps = 60
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(Sheet, 0, 0, Width, Height, rotation: rotation)

      @animations = GSF::Animations.new(:idle, idle)
      @remove = false
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

    def update(frame_time, enemies : Array(Enemy))
      animations.update(frame_time)

      update_movement(frame_time)

      check_distance
      check_enemies(enemies)
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

    def check_enemies(enemies : Array(Enemy))
      enemies.each do |enemy|
        if hit?(enemy.hit_circle)
          enemy.hit!

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
