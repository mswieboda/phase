require "./enemy"

module Phase
  class EnemyKamikaze < Enemy
    Sheet = "./assets/kamikaze.png"

    def self.sheet
      Sheet
    end
  end
end
