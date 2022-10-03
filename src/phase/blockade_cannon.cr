module Phase
  class BlockadeCannon < Cannon
    Sheet = "./assets/blockade_gun.png"
    SpriteWidth = 144
    SpriteHeight = 48

    # def initialize(x = 0_f32, y = 0_f32, rotation = 0)
    #   super

    #   @sprite.origin = {SpriteHeight / 2, SpriteHeight / 2}
    # end

    def self.sheet
      Sheet
    end

    def self.sprite_width
      SpriteWidth
    end

    def self.sprite_height
      SpriteHeight
    end
  end
end
