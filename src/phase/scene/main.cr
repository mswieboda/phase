require "../ship"
require "../hud"
require "../health_obj"
require "../enemy"
require "../enemy_kamikaze"
require "../asteroid"
require "../star_base"

module Phase::Scene
  class Main < GSF::Scene
    getter view : GSF::View
    getter hud
    getter ship
    getter shootables : Array(HealthObj)
    getter bumpables : Array(HealthObj)
    getter star_bases : Array(StarBase)

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      @ship = Ship.new(x: 750, y: 750)
      @hud = HUD.new(ship)
      @shootables = [] of HealthObj
      @bumpables = [] of HealthObj
      @star_bases = [] of StarBase

      enemies = [] of Enemy
      asteroids = [] of Asteroid

      # enemies
      [
        {x: 500, y: 700},
        {x: 300, y: 900},
        {x: 900, y: 100},
        {x: 1500, y: 1500}
      ].each do |coords|
        x = coords[:x] * Screen.scaling_factor
        y = coords[:y] * Screen.scaling_factor
        enemies << Enemy.new(x: x, y: y)
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
        enemies << EnemyKamikaze.new(x: x, y: y)
      end

      [
        {x: 1500, y: 975, type: 1},
        {x: 333, y: 1669, type: 2},
        {x: 2033, y: 489, type: 3}
      ].each do |meta|
        x = meta[:x] * Screen.scaling_factor
        y = meta[:y] * Screen.scaling_factor
        asteroids << Asteroid.new(x: x, y: y, sprite_type: meta[:type])
      end

      @star_bases << StarBase.new(x: 1999, y: 1999)

      @shootables.concat(enemies).concat(asteroids)
      @bumpables.concat(enemies).concat(asteroids).concat(star_bases)
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      update_bumpables(frame_time)

      ship.update(frame_time, keys, mouse, shootables, bumpables)

      view.center(ship.x, ship.y)
      hud.update(frame_time)
    end

    def draw(window)
      # map view
      view.set_current

      bumpables.each(&.draw(window))
      ship.draw(window)

      # default view
      view.set_default_current

      hud.draw(window)
    end

    def update_bumpables(frame_time)
      bumpables.each(&.update(frame_time))

      bumpables.select(&.remove?).each do |bumpable|
        shootables.delete(bumpable)
        bumpables.delete(bumpable)
      end
    end
  end
end
