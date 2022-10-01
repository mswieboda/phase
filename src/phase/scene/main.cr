require "../ship"
require "../hud"
require "../enemy"

module Phase::Scene
  class Main < GSF::Scene
    getter hud
    getter ship
    getter enemies : Array(Enemy)

    def initialize
      super(:main)

      @ship = Ship.new(x: 300, y: 300)
      @hud = HUD.new(ship)
      @enemies = [] of Enemy

      [
        {x: 500, y: 700},
        {x: 300, y: 900},
        {x: 900, y: 100}
      ].each do |coords|
        @enemies << Enemy.new(x: coords[:x], y: coords[:y])
      end
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      ship.update(frame_time, keys, mouse)

      enemies.each(&.update(frame_time))

      hud.update(frame_time)
    end

    def draw(window)
      ship.draw(window)
      enemies.each(&.draw(window))
      hud.draw(window)
    end
  end
end
