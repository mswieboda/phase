require "./box"
require "./arc"

module Phase
  abstract class SuperWeapon
    getter name
    getter? firing

    def initialize(name = "")
      @name = name
      @firing = false
    end

    abstract def draw(window : SF::RenderWindow)
    abstract def hit?(circle : Circle) : Bool
  end
end
