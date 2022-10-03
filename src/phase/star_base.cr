require "./health_obj"

module Phase
  class StarBase < HealthObj
    getter sprite : SF::Sprite

    Sprite = "./assets/star_base_small.png"
    SpriteSize = 900
    HitRadius = 450
    MaxHealth = 1000

    def initialize(x = 0, y = 0)
      super(x, y)

      # sprite
      texture = SF::Texture.from_file(Sprite, SF::IntRect.new(0, 0, SpriteSize, SpriteSize))
      @sprite = SF::Sprite.new(texture)
      @sprite.position = {x, y}
      @sprite.origin = texture.size / 2.0

      @remove = false
    end

    def self.hit_radius
      HitRadius
    end

    def self.max_health
      MaxHealth
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
