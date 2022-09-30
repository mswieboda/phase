require "../ship"
require "../hud"

module Phase::Scene
  class Main < GSF::Scene
    getter hud
    getter ship

    def initialize
      super(:main)

      @ship = Ship.new(x: 300, y: 300)
      @hud = HUD.new
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      ship.update(frame_time, keys)
      hud.update(frame_time)
    end

    def draw(window)
      ship.draw(window)
      hud.draw(window)
    end
  end
end
