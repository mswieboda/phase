require "./circle"

module Phase
  class HealthObj
    getter x : Float64
    getter y : Float64
    getter health : Int32
    getter? remove
    getter? hit
    getter hit_sound
    getter? bumped

    HitRadius = 64
    MaxHealth = 100
    CollisionDamage = 15
    DebugHitBox = true
    HitColor = SF::Color::Red
    UnhitColor = SF::Color::White
    HitSound = SF::SoundBuffer.from_file("./assets/hit.wav")

    def initialize(x = 0, y = 0)
      @x = x
      @y = y
      @health = max_health
      @remove = false
      @hit = false
      @bumped = false
      @hit_sound = SF::Sound.new(HitSound)
      @hit_sound.volume = 33
    end

    def self.hit_radius
      HitRadius
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

    def update(frame_time, bumpables : Array(HealthObj))
      reset_hit_bumped
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

    def move(dx : Float64, dy : Float64)
      @x += dx
      @y += dy
    end

    def bump(dx, dy, bumped_by, bumpables)
      return if bumped?

      @bumped = true

      move(dx, dy)

      bumpables.each do |bumpable|
        next if bumpable == self
        next if bumpable == bumped_by
        next if bumpable.is_a?(EnemyCarrier)

        if hit?(bumpable.hit_circle)
          move(-dx, -dy)
          bumpable.bump(dx, dy, self, bumpables)
        end
      end
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

    def reset_hit_bumped
      @hit = false
      @bumped = false
    end

    def rotation_to(other_x, other_y)
      target_rotation = rotation_from(other_x, other_y) + 180

      target_rotation < 360 ? target_rotation : target_rotation - 360
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

      radians = 0

      if dx == 0
        if dy > 0
          radians = Math::PI / 2
        elsif dy < 0
          radians = 3 * Math::PI / 2
        end
      else
        radians = Math.atan(dy / dx) + (dx < 0 ? Math::PI : 0)
      end

      target_rotation = radians * 180 / Math::PI

      target_rotation < 360 ? target_rotation : target_rotation - 360
    end

    def distance(obj : HealthObj)
      distance(obj.x, obj.y, obj.hit_radius)
    end

    def distance(cx, cy, radius = 0)
      Calc.distance(x, y, cx, cy) - radius
    end
  end
end
