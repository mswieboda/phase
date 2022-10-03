module Phase
  class Cannon
    getter rotation : Float64
    getter sprite

    Sheet = "./assets/cannon.png"
    SpriteWidth = 80
    SpriteHeight = 32

    def initialize(x = 0_f32, y = 0_f32, rotation = 0)
      @rotation = rotation

      texture = SF::Texture.from_file(sheet, SF::IntRect.new(0, 0, sprite_width, sprite_height))
      @sprite = SF::Sprite.new(texture)
      @sprite.position = {x, y}
      @sprite.origin = {sprite_height / 2, sprite_height / 2}
      @sprite.rotation = rotation
    end

    def self.sheet
      Sheet
    end

    def sheet
      self.class.sheet
    end

    def self.sprite_width
      SpriteWidth
    end

    def sprite_width
      self.class.sprite_width
    end

    def self.sprite_height
      SpriteHeight
    end

    def sprite_height
      self.class.sprite_height
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
