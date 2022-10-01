module Phase
  class Cannon
    getter rotation : Float64
    getter sprite

    SpriteFile = "./assets/cannon.png"
    SpriteWidth = 80
    SpriteHeight = 32

    def initialize(x = 0_f32, y = 0_f32, rotation = 0)
      @rotation = rotation

      texture = SF::Texture.from_file(SpriteFile, SF::IntRect.new(0, 0, width, height))
      @sprite = SF::Sprite.new(texture)
      sprite.position = {x, y}
      @sprite.origin = {height / 2, height / 2} # TODO: maybe tweak so not pivoted completely at the point
      @sprite.rotation = rotation
    end

    def self.width
      SpriteWidth
    end

    def width
      self.class.width
    end

    def self.height
      SpriteHeight
    end

    def height
      self.class.height
    end

    def update(frame_time, x, y, rotation : Float64)
      move(x, y)

      update_movement(rotation)
    end

    def update_movement(rotation : Float64)
      sprite.rotation = rotation
    end

    def draw(window : SF::RenderWindow)
      window.draw(sprite)
    end

    def move(x, y)
      sprite.position = {x, y}
    end
  end
end
