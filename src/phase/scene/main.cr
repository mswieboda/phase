require "../ship"
require "../hud"
require "../health_obj"
require "../enemy_static"
require "../enemy_kamikaze"
require "../enemy_ship"
require "../enemy_group"
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
    getter enemy_ships : Array(EnemyShip)
    getter enemy_groups : Array(EnemyGroup)

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      @ship = Ship.new(x: 1000, y: 1000)
      @hud = HUD.new(ship)
      @shootables = [] of HealthObj
      @bumpables = [] of HealthObj
      @star_bases = [] of StarBase
      @enemy_ships = [] of EnemyShip
      @enemy_groups = [] of EnemyGroup

      enemies = [] of Enemy
      asteroids = [] of Asteroid

      # enemies (static)
      [
        {x: 500, y: 700},
        {x: 300, y: 900},
        {x: 900, y: 100},
        {x: 1500, y: 1500}
      ].each do |coords|
        x = coords[:x] * Screen.scaling_factor
        y = coords[:y] * Screen.scaling_factor
        enemies << EnemyStatic.new(x: x, y: y)
      end

      # kamikaze enemies
      [
        {x: 100, y: 300},
        {x: 300, y: 300}
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

      # enemy ships
      enemy_group = [] of EnemyShip
      [
        {x: 600, y: 150},
        {x: 500, y: 100},
        {x: 400, y: 200}
      ].each do |coords|
        x = coords[:x] * Screen.scaling_factor
        y = coords[:y] * Screen.scaling_factor
        # @enemy_ships << EnemyShip.new(x: x, y: y, star_base: @star_bases.first)
        enemy_group << EnemyShip.new(x: x, y: y, star_base: @star_bases.first)
      end

      @enemy_groups << EnemyGroup.new(star_base: @star_bases.first, enemies: enemy_group)

      @shootables.concat(enemies).concat(@enemy_ships).concat(asteroids)
      @bumpables.concat(enemies).concat(@enemy_ships).concat(asteroids).concat(star_bases)
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      update_bumpables(frame_time)
      enemy_groups.each(&.update(frame_time, @star_bases))
      ship.update(frame_time, keys, mouse, shootables, bumpables)

      view.center(ship.x, ship.y)
      hud.update(frame_time)
    end

    def draw(window)
      # map view
      view.set_current

      bumpables.each(&.draw(window))
      enemy_groups.flat_map(&.enemies).each(&.draw(window))
      ship.draw(window)

      # default view
      view.set_default_current

      hud.draw(window)
    end

    def update_bumpables(frame_time)
      bumpables.each do |bumpable|
        if bumpable.is_a?(EnemyShip)
          bumpable.update(frame_time, @star_bases)
        else
          bumpable.update(frame_time)
        end
      end

      bumpables.select(&.remove?).each do |bumpable|
        shootables.delete(bumpable)
        bumpables.delete(bumpable)
      end
    end
  end
end
