require "../ship"
require "../hud"
require "../health_obj"
require "../enemy_static"
require "../enemy_kamikaze"
require "../enemy_ship"
require "../enemy_carrier"
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
    getter enemy_groups : Array(EnemyGroup)
    getter enemy_carriers : Array(EnemyCarrier)

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      @ship = Ship.new(x: 1000, y: 1000)
      @hud = HUD.new(ship)
      @shootables = [] of HealthObj
      @bumpables = [] of HealthObj
      @star_bases = [] of StarBase
      @enemy_carriers = [] of EnemyCarrier
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
        enemy_group << EnemyShip.new(x: x, y: y)
      end

      @enemy_groups << EnemyGroup.new(star_bases: @star_bases, enemies: enemy_group)

      # enemy carriers
      [
        {x: 0, y: 1000, target_x: 900, target_y: 100}
      ].each do |coords|
        x = coords[:x] * Screen.scaling_factor
        y = coords[:y] * Screen.scaling_factor
        target_x = coords[:target_x] * Screen.scaling_factor
        target_y = coords[:target_y] * Screen.scaling_factor
        @enemy_carriers << EnemyCarrier.new(x: x, y: y, target_x: target_x, target_y: target_y, star_bases: @star_bases)
      end

      @shootables
        .concat(enemies)
        .concat(enemy_carriers)
        .concat(enemy_groups.flat_map(&.enemies))
        .concat(asteroids)

      @bumpables
        .concat(enemies)
        .concat(enemy_carriers)
        .concat(enemy_groups.flat_map(&.enemies))
        .concat(asteroids)
        .concat(star_bases)
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      update_bumpables(frame_time)
      update_enemy_carriers
      enemy_groups.each(&.update(frame_time))
      ship.update(frame_time, keys, mouse, shootables, bumpables)

      view.center(ship.x, ship.y)
      hud.update(frame_time)
    end

    def draw(window)
      # map view
      view.set_current

      bumpables.each(&.draw(window))
      # enemy_groups.flat_map(&.enemies).each(&.draw(window))
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

        enemy_groups.each do |enemy_group|
          enemy_group.enemies.delete(bumpable)

          if enemy_group.enemies.empty?
            enemy_groups.delete(enemy_group)
          end
        end
      end
    end

    def update_enemy_carriers
      enemy_carriers.each do |enemy_carrier|
        if enemy_group = enemy_carrier.enemy_group
          @enemy_groups << enemy_group

          @shootables.concat(enemy_group.enemies)
          @bumpables.concat(enemy_group.enemies)

          enemy_carrier.finish_drop_off
        end
      end
    end
  end
end
