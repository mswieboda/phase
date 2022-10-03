require "./enemy"

module Phase
  class EnemyKamikaze < Enemy
    Sheet = "./assets/kamikaze.png"
    ScoreValue = 5

    def self.sheet
      Sheet
    end

    def self.score_value
      ScoreValue
    end
  end
end
