require "./box"
require "./arc"

module Phase
  abstract class SuperWeapon
    getter? firing

    def initialize
      @firing = false
    end

    abstract def draw(window : SF::RenderWindow)
    abstract def hit?(circle : Circle) : Bool
  end
end
