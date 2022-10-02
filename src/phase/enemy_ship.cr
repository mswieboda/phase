require "./enemy"

module Phase
  class EnemyShip < Enemy
    Sheet = "./assets/enemy.png"
    Size = 128
    HitRadius = 64

    def initialize(x = 0, y = 0)
      super(x, y, Sheet)
    end

    def self.hit_radius
      HitRadius * Screen.scaling_factor
    end
  end
end
