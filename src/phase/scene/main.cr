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
    getter objs : Array(HealthObj)
    getter star_bases : Array(StarBase)
    getter enemy_groups : Array(EnemyGroup)
    getter enemy_carriers : Array(EnemyCarrier)
    getter lasers : Array(Laser)
    getter game_over_timer : Timer
    getter? restart

    GameOverWaitDuration = 500.milliseconds

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      view.zoom(1 / Screen.scaling_factor)

      @ship = Ship.new(x: 1000, y: 1000)
      @hud = HUD.new(ship)
      @game_over_timer = Timer.new(GameOverWaitDuration)
      @restart = false

      @objs = [] of HealthObj
      @star_bases = [] of StarBase
      @enemy_carriers = [] of EnemyCarrier
      @enemy_groups = [] of EnemyGroup
      @lasers = [] of Laser

      enemies = [] of Enemy
      asteroids = [] of Asteroid

      # enemies (static)
      [
        {x: 500, y: 700},
        {x: 300, y: 900},
        {x: 1500, y: 1500}
      ].each do |coords|
        x = coords[:x]
        y = coords[:y]
        enemies << EnemyStatic.new(x: x, y: y)
      end

      # kamikaze enemies
      [
        {x: 100, y: 300},
        {x: 300, y: 300}
      ].each do |coords|
        x = coords[:x]
        y = coords[:y]
        enemies << EnemyKamikaze.new(x: x, y: y)
      end

      [
        {x: 1500, y: 975, type: 1},
        {x: 333, y: 1669, type: 2},
        {x: 2033, y: 489, type: 3}
      ].each do |meta|
        x = meta[:x]
        y = meta[:y]
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
        x = coords[:x]
        y = coords[:y]
        enemy_group << EnemyShip.new(x: x, y: y)
      end

      @enemy_groups << EnemyGroup.new(star_bases: @star_bases, enemies: enemy_group)

      # enemy carriers
      [
        {x: 0, y: 1000, target_x: 900, target_y: 100}
      ].each do |coords|
        x = coords[:x]
        y = coords[:y]
        target_x = coords[:target_x]
        target_y = coords[:target_y]
        @enemy_carriers << EnemyCarrier.new(x: x, y: y, target_x: target_x, target_y: target_y, star_bases: @star_bases)
      end

      @objs << ship
      @objs
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

      if keys.just_pressed?(Keys::Enter)
        @restart = true
      end

      if game_over?
        if game_over_timer.done?
          hud.update(frame_time, game_over?, game_over_message)
          return
        else
          game_over_timer.start unless game_over_timer.started?
        end
      end

      ship.update(frame_time, keys, mouse, objs)
      update_objs(frame_time)
      add_lasers
      update_lasers(frame_time)
      update_enemy_carriers
      enemy_groups.each(&.update(frame_time, objs))

      view.center(ship.x, ship.y)
      hud.update(frame_time, false, nil)
    end

    def draw(window)
      # map view
      view.set_current

      objs.each(&.draw(window))
      lasers.each(&.draw(window))

      # default view
      view.set_default_current

      hud.draw(window)
    end

    def update_objs(frame_time)
      objs.each(&.update(frame_time, objs))

      objs.select(&.remove?).each do |obj|
        objs.delete(obj)

        if obj.is_a?(EnemyShip)
          enemy_groups.each do |enemy_group|
            enemy_group.enemies.delete(obj)

            if enemy_group.enemies.empty?
              enemy_groups.delete(enemy_group)
            end
          end
        end

        if obj.is_a?(StarBase)
          star_bases.delete(obj)
        end
      end
    end

    def update_lasers(frame_time)
      lasers.each(&.update(frame_time, objs))
      lasers.select(&.remove?).each do |laser|
        lasers.delete(laser)
      end
    end

    def update_enemy_carriers
      enemy_carriers.each do |enemy_carrier|
        if enemy_group = enemy_carrier.enemy_group
          @enemy_groups << enemy_group

          @objs.concat(enemy_group.enemies)

          enemy_carrier.finish_drop_off
        end
      end
    end

    def add_lasers
      @enemy_groups.flat_map(&.enemies).each do |enemy_ship|
        if laser = enemy_ship.laser
          @lasers << laser
        end
      end
    end

    def game_over?
      star_bases.empty? || ship.remove?
    end

    def game_over_message
      if ship.remove?
        "you were destroyed"
      elsif star_bases.empty?
        "star bases were destroyed"
      else
        nil
      end
    end
  end
end
