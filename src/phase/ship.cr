require "./pulse"
require "./laser"
require "./cannon"
require "./super_weapon"
require "./super_cannon"

module Phase
  class Ship
    alias ThrusterAnimationsTuple = NamedTuple(
      playing: Array(Symbol),
      animations: NamedTuple(
        top: GSF::Animations,
        left: GSF::Animations,
        bottom: GSF::Animations,
        right: GSF::Animations
      )
    )

    getter x : Float64
    getter y : Float64
    getter animations
    getter pulse : Pulse
    getter thrusters : ThrusterAnimationsTuple
    getter fire_timer : Timer
    getter lasers : Array(Laser)
    getter cannon : Cannon
    getter super_weapon : SuperWeapon
    getter super_weapons : Array(SuperWeapon)
    getter super_cannon : SuperCannon
    getter super_weapon_timer : Timer

    Speed = 666
    Sheet = "./assets/ship.png"
    ShipSize = 128
    ThrusterSheet = "./assets/thruster.png"
    ThrusterSize = 64
    FireDuration = 150.milliseconds
    SuperWeaponDuration = 10.seconds

    def initialize(x = 0, y = 0)
      @x = x
      @y = y
      @pulse = Pulse.new(x, y)
      @super_cannon = SuperCannon.new(x, y)
      @super_weapons = [] of SuperWeapon
      @super_weapons << @pulse
      @super_weapons << @super_cannon
      @super_weapon = @super_cannon
      @super_weapon_timer = Timer.new(SuperWeaponDuration)

      fps = 60

      # ship animations
      # idle
      idle_size = size
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(Sheet, 0, 0, idle_size, idle_size)

      @animations = GSF::Animations.new(:idle, idle)

      # thruster animations
      move_size = ThrusterSize
      move_frames = 8
      move_factor = 20
      top = GSF::Animation.new((fps / move_factor).to_i, loops: false)

      move_frames.times do |index|
        top.add(ThrusterSheet, move_size * index, 0, move_size, move_size, rotation: 90)
      end

      left = GSF::Animation.new((fps / move_factor).to_i, loops: false)

      move_frames.times do |index|
        left.add(ThrusterSheet, move_size * index, 0, move_size, move_size)
      end

      bottom = GSF::Animation.new((fps / move_factor).to_i, loops: false)

      move_frames.times do |index|
        bottom.add(ThrusterSheet, move_size * index, 0, move_size, move_size, rotation: -90)
      end

      right = GSF::Animation.new((fps / move_factor).to_i, loops: false)

      move_frames.times do |index|
        right.add(ThrusterSheet, move_size * index, 0, move_size, move_size, flip_horizontal: true)
      end

      @thrusters = {
        playing: [] of Symbol,
        animations: {
          top: GSF::Animations.new(:move, top),
          left: GSF::Animations.new(:move, left),
          bottom: GSF::Animations.new(:move, bottom),
          right: GSF::Animations.new(:move, right),
        }
      }

      @fire_timer = Timer.new(FireDuration)
      @lasers = [] of Laser
      @cannon = Cannon.new(x, y)
    end

    def self.size
      ShipSize
    end

    def size
      self.class.size
    end

    def update(frame_time, keys : Keys, mouse : Mouse, enemies : Array(Enemy))
      animations.update(frame_time)

      thrusters[:animations].each do |dir, a|
        a.update(frame_time)
      end

      update_movement(frame_time, keys)
      update_cannon(frame_time, mouse, enemies)
      update_super_weapon(frame_time, mouse, enemies)
    end

    def update_movement(frame_time, keys : Keys)
      dx = 0_f64
      dy = 0_f64
      speed = Speed * frame_time

      dy -= speed if keys.pressed?(Keys::W)
      dx -= speed if keys.pressed?(Keys::A)
      dy += speed if keys.pressed?(Keys::S)
      dx += speed if keys.pressed?(Keys::D)

      reset_thrusters

      if dx != 0 && dy != 0
        # 45 deg, from sqrt(x^2 + y^2) at 45 deg
        const = 0.70710678118_f64
        dx *= const
        dy *= const
      end

      dx = 0_f64 if x + dx < 0
      dy = 0_f64 if y + dy < 0

      move(dx, dy) if dx != 0_f64 || dy != 0_f64
    end

    def update_cannon(frame_time, mouse : Mouse, enemies : Array(Enemy))
      cannon.update(frame_time, x, y, mouse.to_rotation(x, y))
      update_firing(mouse)
      lasers.each(&.update(frame_time, enemies))
      lasers.select(&.remove?).each do |laser|
        lasers.delete(laser)
      end
    end

    def update_super_weapon(frame_time, mouse : Mouse, enemies : Array(Enemy))
      if super_weapon == pulse
        pulse.update(frame_time, super_weapon_timer.done?, x, y, enemies)
      elsif super_weapon == super_cannon
        super_cannon.update(frame_time, super_weapon_timer.done?, x, y, mouse.to_rotation(x, y), enemies)
      end

      if !super_weapon_timer.started? || super_weapon_timer.done?
        super_weapon_timer.restart
      end
    end

    def update_firing(mouse)
      if mouse.pressed?(Mouse::Left)
        if fire_timer.started?
          if fire_timer.done?
            fire(mouse)

            fire_timer.restart
          end
        else
          fire_timer.start

          fire(mouse)
        end
      else
        fire_timer.stop
      end
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y)

      [:top, :left, :bottom, :right].each do |dir|
        if thrusters[:playing].includes?(dir)
          draw_x = x
          draw_y = y

          case dir
          when :top
            draw_y = draw_y - size / 2 - ThrusterSize / 2
          when :left
            draw_x = draw_x - size / 2 - ThrusterSize / 2
          when :bottom
            draw_y = draw_y + size / 2 + ThrusterSize / 2
          when :right
            draw_x = draw_x + size / 2 + ThrusterSize / 2
          end

          thrusters[:animations][dir].draw(window, draw_x, draw_y)
        end
      end

      lasers.each(&.draw(window))
      super_weapon.draw(window)
      cannon.draw(window)
    end

    def fire(mouse : Mouse)
      @lasers << Laser.new(x, y, mouse.to_rotation(x, y))
    end

    def play_thruster(dir : Symbol)
      animation = thrusters[:animations][dir]

      return unless animation.done?

      thrusters[:playing] << dir unless thrusters[:playing].includes?(dir)

      animation.play(:move)
    end

    def reset_thrusters
      thrusters[:playing].each do |dir|
        if thrusters[:animations][dir].done?
          thrusters[:playing].delete(dir)
        end
      end
    end

    def move(dx : Float64, dy : Float64)
      @x += dx
      @y += dy

      play_thruster(:top) if dy > 0
      play_thruster(:left) if dx > 0
      play_thruster(:bottom) if dy < 0
      play_thruster(:right) if dx < 0
    end
  end
end
