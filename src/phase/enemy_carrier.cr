require "./enemy"

module Phase
  class EnemyCarrier < Enemy
    Sheet = "./assets/carrier.png"
    SpriteWidth = 384
    SpriteHeight = 256
    HitRadius = 128
    MaxHealth = 1000

    def self.sheet
      Sheet
    end

    def self.sprite_width
      SpriteWidth
    end

    def self.sprite_height
      SpriteHeight
    end

    def self.hit_radius
      HitRadius * Screen.scaling_factor
    end

    def self.max_health
      MaxHealth
    end
  end
end
