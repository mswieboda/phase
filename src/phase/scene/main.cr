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
    getter score : Int32

    GameOverWaitDuration = 500.milliseconds

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      view.zoom(1 / Screen.scaling_factor)

      @ship = Ship.new(x: 1989, y: 1999)
      @hud = HUD.new(ship)
      @game_over_timer = Timer.new(GameOverWaitDuration)
      @restart = false
      @score = 0

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

      # asteroids
      [
        {x: 4900, y: 200},
        {x: 5180, y: 180},
        {x: 5420, y: 240},
        {x: 4840, y: 460},
        {x: 5140, y: 460},
        {x: 5440, y: 480},
        {x: 4620, y: 790},
        {x: 4920, y: 770},
        {x: 5380, y: 840},
        {x: 5140, y: 940},
        {x: 4720, y: 1060},
        {x: 4950, y: 1130},
        {x: 5300, y: 1140},
        {x: 4490, y: 1130},
        {x: 4500, y: 1380},
        {x: 4960, y: 1330},
        {x: 5200, y: 1380},
        {x: 4290, y: 1510},
        {x: 4530, y: 1670},
        {x: 4810, y: 1650},
        {x: 5120, y: 1650},
        {x: 4680, y: 1800},
        {x: 4350, y: 1930},
        {x: 4770, y: 2010},
        {x: 5030, y: 1950},
        {x: 4930, y: 2270},
        {x: 4480, y: 2280},
        {x: 4140, y: 2300},
        {x: 3970, y: 2580},
        {x: 4180, y: 2580},
        {x: 4700, y: 2600},
        {x: 3670, y: 2920},
        {x: 3920, y: 2920},
        {x: 4180, y: 2960},
        {x: 4520, y: 3040},
        {x: 3500, y: 3150},
        {x: 3700, y: 3300},
        {x: 4000, y: 3280},
        {x: 4240, y: 3380},
        {x: 3290, y: 3330},
        {x: 3940, y: 3480},
        {x: 3090, y: 3490},
        {x: 3380, y: 3560},
        {x: 3600, y: 3600},
        {x: 3960, y: 3720},
        {x: 2870, y: 3700},
        {x: 3100, y: 3760},
        {x: 3300, y: 3960},
        {x: 3660, y: 3960},
        {x: 2720, y: 3920},
        {x: 2920, y: 4060},
        {x: 2440, y: 4160},
        {x: 2680, y: 4380},
        {x: 3060, y: 4300},
        {x: 3360, y: 4340},
        {x: 3610, y: 4310},
        {x: 2220, y: 4360},
        {x: 2920, y: 4560},
        {x: 2000, y: 4560},
        {x: 1800, y: 4600},
        {x: 2240, y: 4700},
        {x: 2440, y: 4640},
        {x: 2700, y: 4720},
        {x: 2940, y: 4780},
        {x: 3200, y: 4680},
        {x: 1520, y: 4880},
        {x: 1700, y: 4880},
        {x: 2020, y: 4900},
        {x: 2420, y: 4960},
        {x: 2660, y: 4940},
        {x: 1160, y: 5060},
        {x: 1430, y: 5190},
        {x: 1840, y: 5100},
        {x: 2180, y: 5140},
        {x: 2520, y: 5220},
        {x: 970, y: 5290},
        {x: 1780, y: 5340},
        {x: 2080, y: 5340},
        {x: 2660, y: 4940},
        {x: 900, y: 5520},
        {x: 1160, y: 5510},
        {x: 1420, y: 5550},
        {x: 500, y: 5630},
        {x: 1260, y: 5700},
        {x: 1760, y: 5740},
        {x: 1440, y: 5840},
        {x: 1060, y: 5820},
        {x: 790, y: 5800},
        {x: 200, y: 5780},
        {x: 530, y: 5920},
        {x: 750, y: 6050},
        {x: 300, y: 6130},
        {x: 460, y: 6360},
        {x: 1020, y: 6240}
      ].each do |coords|
        asteroids << Asteroid.new(x: coords[:x], y: coords[:y], sprite_type: rand(3) + 1)
      end

      [
        {x: 2_600, y: 2_400},
        {x: 6_600, y: 6_400},
        {x: 11_700, y: 3_620}
      ].each do |coords|
        @star_bases << StarBase.new(x: coords[:x], y: coords[:y])
      end

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
          ship.super_weapon_timer.pause
          hud.update(frame_time, score, game_over?, game_over_message)
          return
        else
          game_over_timer.start unless game_over_timer.started?
        end
      end

      update_objs(frame_time)
      ship.update(frame_time, keys, mouse, objs)
      add_lasers
      update_lasers(frame_time)
      update_enemy_carriers
      enemy_groups.each(&.update(frame_time, objs))

      view.center(ship.x, ship.y)
      hud.update(frame_time, score, false, nil)
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
      objs.each do |obj|
        next if obj == ship

        obj.update(frame_time, objs)
      end

      objs.select(&.remove?).each do |obj|
        objs.delete(obj)

        if obj.is_a?(Enemy)
          enemy = obj.as(Enemy)

          @score += obj.score_value
        end

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

      if laser = ship.laser
        @lasers << laser
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
