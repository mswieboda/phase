require "./circle"

module Phase
  class HealthObj
    getter x : Float64
    getter y : Float64
    getter health : Int32
    getter? remove
    getter? hit

    Sprite = "./assets/star_base_small.png"
    Size = 900
    HitRadius = 450
    MaxHealth = 100
    CollisionDamage = 15
    DebugHitBox = false
    HitColor = SF::Color::Red
    UnhitColor = SF::Color::White

    def initialize(x = 0, y = 0)
      @x = x
      @y = y
      @health = max_health
      @remove = false
      @hit = false
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

    def health_color
      hit? ? HitColor : UnhitColor
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
  end
end
