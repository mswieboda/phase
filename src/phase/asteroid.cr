require "./health_obj"

module Phase
  class Asteroid < HealthObj
    getter sprite : SF::Sprite

    SpriteSize = 256
    HitRadius = 128

    def initialize(x = 0, y = 0, sprite_type = 1, rotation = 0)
      super(x, y)

      @rotation = rotation

      # sprite
      texture_file = "./assets/small_asteroid_#{sprite_type}.png"
      texture = SF::Texture.from_file(texture_file, SF::IntRect.new(0, 0, SpriteSize, SpriteSize))
      @sprite = SF::Sprite.new(texture)
      @sprite.position = {x, y}
      @sprite.origin = texture.size / 2.0
      @sprite.rotation = rotation

      @remove = false
    end

    def self.hit_radius
      HitRadius
    end

    def draw(window : SF::RenderWindow)
      sprite.position = {x, y}
      sprite.color = health_color

      window.draw(sprite)
      draw_hit_circle(window)
    end

    def static?
      true
    end

    def bump(dx, dy, bumped_by, objs)
      bumped_by.move(-dx, -dy)
    end
  end
end
