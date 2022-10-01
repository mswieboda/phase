require "../ship"
require "../hud"
require "../enemy"
require "../enemy_kamikaze"

module Phase::Scene
  class Main < GSF::Scene
    getter hud
    getter ship
    getter enemies : Array(Enemy)

    def initialize
      super(:main)

      @ship = Ship.new(x: 750, y: 750)
      @hud = HUD.new(ship)
      @enemies = [] of Enemy

      [
        {x: 500, y: 700},
        {x: 300, y: 900},
        {x: 900, y: 100},
        {x: 1500, y: 1500}
      ].each do |coords|
        @enemies << Enemy.new(x: coords[:x], y: coords[:y])
      end

      [
        {x: 100, y: 300},
        {x: 300, y: 300},
        {x: 500, y: 300},
        {x: 700, y: 300},
        {x: 900, y: 300}
      ].each do |coords|
        @enemies << EnemyKamikaze.new(x: coords[:x], y: coords[:y])
      end
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      update_enemies(frame_time)

      ship.update(frame_time, keys, mouse, enemies)

      hud.update(frame_time)
    end

    def draw(window)
      enemies.each(&.draw(window))
      ship.draw(window)
      hud.draw(window)
    end

    def update_enemies(frame_time)
      enemies.each(&.update(frame_time))

      enemies.select(&.remove?).each do |enemy|
        enemies.delete(enemy)
      end
    end
  end
end
