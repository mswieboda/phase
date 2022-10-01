require "./circle"
require "./enemy"

module Phase
  class EnemyKamikaze < Enemy
    Sheet = "./assets/kamikaze.png"
    Size = 128
    HitRadius = 64

    def initialize(x = 0, y = 0)
      super(x, y, Sheet)
    end

    def self.size
      Size
    end

    def self.hit_radius
      HitRadius
    end
  end
end
