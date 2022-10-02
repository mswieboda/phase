require "./circle"

module Phase
  class HealthObj
    getter x : Float64
    getter y : Float64
    getter health : Int32
    getter? remove
    getter? hit
    getter hit_sound

    Sprite = "./assets/star_base_small.png"
    Size = 900
    HitRadius = 450
    MaxHealth = 100
    CollisionDamage = 15
    DebugHitBox = false
    HitColor = SF::Color::Red
    UnhitColor = SF::Color::White
    HitSound = SF::SoundBuffer.from_file("./assets/hit.wav")

    def initialize(x = 0, y = 0)
      @x = x
      @y = y
      @health = max_health
      @remove = false
      @hit = false
      @hit_sound = SF::Sound.new(HitSound)
      @hit_sound.volume = 13
    end

    def self.hit_radius
      HitRadius * Screen.scaling_factor
    end

    def hit_radius
      self.class.hit_radius
    end

    def self.max_health
      MaxHealth
    end

    def max_health
      self.class.max_health
    end

    def self.collision_damage
      CollisionDamage
    end

    def collision_damage
      self.class.collision_damage
    end

    def self.unhit_color
      UnhitColor
    end

    def unhit_color
      self.class.unhit_color
    end

    def health_color
      hit? ? HitColor : unhit_color
    end

    def update(frame_time)
      reset_hit
    end

    def draw(window : SF::RenderWindow)
      draw_hit_circle(window)
    end

    def draw_hit_circle(window : SF::RenderWindow)
      return unless DebugHitBox

      hc = hit_circle
      circle = SF::CircleShape.new(hc.radius)
      circle.fill_color = SF.color(0, 0, 0, 0)
      circle.outline_thickness = 2
      circle.outline_color = SF.color(250, 150, 100)
      circle.origin = {hc.radius, hc.radius}
      circle.position = {hc.x, hc.y}

      window.draw(circle)
    end

    def hit_circle
      Circle.new(x: x, y: y, radius: hit_radius)
    end

    def hit?(circle : Circle)
      hit_circle.intersects?(circle)
    end

    def hit(damage : Int32)
      hit_sound.play

      @hit = true
      @health -= damage

      if @health <= 0
        @health = 0
        @remove = true
      end
    end

    def reset_hit
      @hit = false
    end

    def rotation_to(obj : HealthObj)
      obj.rotation_from(self)
    end

    def rotation_from(obj : HealthObj)
      rotation_from(obj.x, obj.y)
    end

    def rotation_from(other_x, other_y)
      dx = x - other_x
      dy = y - other_y

      if dx == 0
        if dy > 0
          return Math::PI / 2
        elsif dy < 0
          return -Math::PI / 2
        else
          return 0_f64
        end
      end

      radians = Math.atan(dy / dx) + (dx < 0 ? Math::PI : 0_f64)

      radians * 180 / Math::PI
    end

    def distance(obj : HealthObj)
      dx = x - obj.x
      dy = y - obj.y

      Math.sqrt(dx * dx + dy * dy) - obj.hit_radius
    end
  end
end
