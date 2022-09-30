require "game_sf"

require "./phase/game"

module Phase
  alias Keys = GSF::Keys
  alias Mouse = GSF::Mouse
  alias Joysticks = GSF::Joysticks
  alias Screen = GSF::Screen

  Game.new.run
end
