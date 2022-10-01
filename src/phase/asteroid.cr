module Phase
  class Asteroid
    getter x
    getter y
    getter sprite : SF::Sprite
    getter? remove

    Size = 256
    Height = 16
    HitRadius = 128
    Damage = 15

    def initialize(x = 0, y = 0, sprite_type = 1, rotation = 0)
      @x = x
      @y = y
      @init_x = x
      @init_y = y
      @rotation = rotation

      # sprite
      texture = SF::Texture.from_file("./assets/small_asteroid_#{sprite_type}.png", SF::IntRect.new(0, 0, Size, Size))
      @sprite = SF::Sprite.new(texture)
      @sprite.position = {x, y}
      @sprite.origin = texture.size / 2.0
      @sprite.rotation = rotation

      @remove = false
    end

    def self.hit_radius
      HitRadius
    end

    def hit_radius
      self.class.hit_radius
    end

    def update(frame_time)
    end

    def draw(window : SF::RenderWindow)
      window.draw(sprite)
    end

    def hit_circle
      Circle.new(x: x, y: y, radius: hit_radius)
    end

    def hit?(circle : Circle)
      hit_circle.intersects?(circle)
    end
  end
end
