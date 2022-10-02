require "../ship"
require "../hud"
require "../enemy"
require "../enemy_kamikaze"
require "../asteroid"

module Phase::Scene
  class Main < GSF::Scene
    getter view : GSF::View
    getter hud
    getter ship
    getter enemies : Array(Enemy)
    getter asteroids : Array(Asteroid)

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      @ship = Ship.new(x: 750, y: 750)
      @hud = HUD.new(ship)
      @enemies = [] of Enemy
      @asteroids = [] of Asteroid

      # enemies
      [
        {x: 500, y: 700},
        {x: 300, y: 900},
        {x: 900, y: 100},
        {x: 1500, y: 1500}
      ].each do |coords|
        x = coords[:x] * Screen.scaling_factor
        y = coords[:y] * Screen.scaling_factor
        @enemies << Enemy.new(x: x, y: y)
      end

      # kamikaze enemies
      [
        {x: 100, y: 300},
        {x: 300, y: 300},
        {x: 500, y: 300},
        {x: 700, y: 300},
        {x: 900, y: 300}
      ].each do |coords|
        x = coords[:x] * Screen.scaling_factor
        y = coords[:y] * Screen.scaling_factor
        @enemies << EnemyKamikaze.new(x: x, y: y)
      end

      [
        {x: 1500, y: 975, type: 1},
        {x: 333, y: 1669, type: 2},
        {x: 2033, y: 489, type: 3}
      ].each do |meta|
        x = meta[:x] * Screen.scaling_factor
        y = meta[:y] * Screen.scaling_factor
        @asteroids << Asteroid.new(x: x, y: y, sprite_type: meta[:type])
      end
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      update_enemies(frame_time)

      ship.update(frame_time, keys, mouse, enemies)
      view.center(ship.x, ship.y)
      hud.update(frame_time)
    end

    def draw(window)
      # map view
      view.set_current

      enemies.each(&.draw(window))
      ship.draw(window)
      asteroids.each(&.draw(window))

      # default view
      view.set_default_current

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
