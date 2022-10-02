module Phase
  class StarBase
    getter x : Float64
    getter y : Float64
    getter sprite : SF::Sprite
    getter? remove

    Sprite = "./assets/star_base_small.png"
    Size = 900
    HitRadius = 450

    def initialize(x = 0, y = 0)
      @x = x
      @y = y

      # sprite
      texture = SF::Texture.from_file(Sprite, SF::IntRect.new(0, 0, Size, Size))
      @sprite = SF::Sprite.new(texture)
      @sprite.position = {x, y}
      @sprite.origin = texture.size / 2.0

      @remove = false
    end

    def self.hit_radius
      HitRadius * Screen.scaling_factor
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
