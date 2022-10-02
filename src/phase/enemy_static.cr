require "./enemy"

module Phase
  class EnemyStatic < Enemy
    UnhitColor = SF::Color.new(128, 128, 255)

    def self.unhit_color
      UnhitColor
    end
  end
end
