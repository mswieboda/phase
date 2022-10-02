require "./health_obj"
require "./laser"
require "./cannon"
require "./super_weapon"
require "./pulse"
require "./beam"

module Phase
  class Ship < HealthObj
    alias ThrusterAnimationsTuple = NamedTuple(
      playing: Array(Symbol),
      animations: NamedTuple(
        top: GSF::Animations,
        left: GSF::Animations,
        bottom: GSF::Animations,
        right: GSF::Animations
      )
    )

    getter animations
    getter thrusters : ThrusterAnimationsTuple
    getter fire_timer : Timer
    getter lasers : Array(Laser)
    getter cannon : Cannon
    getter super_weapon : SuperWeapon
    getter super_weapons : Array(SuperWeapon)
    getter pulse : Pulse
    getter beam : Beam
    getter super_weapon_timer : Timer

    Speed = 666
    Sheet = "./assets/ship.png"
    ShipSize = 128
    HitRadius = 64
    ThrusterSheet = "./assets/thruster.png"
    ThrusterSize = 64
    FireDuration = 150.milliseconds
    SuperWeaponDuration = 10.seconds
    BumpBackFactor = 3

    def initialize(x = 0, y = 0)
      super(x, y)

      @pulse = Pulse.new(x, y)
      @beam = Beam.new(x, y)
      @super_weapons = [] of SuperWeapon
      @super_weapons << @pulse
      @super_weapons << @beam
      @super_weapon = @super_weapons.first
      @super_weapon_timer = Timer.new(SuperWeaponDuration)

      fps = 60

      # ship animations
      # idle
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(Sheet, 0, 0, ShipSize, ShipSize)

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
      ShipSize * Screen.scaling_factor
    end

    def size
      self.class.size
    end

    def self.hit_radius
      HitRadius * Screen.scaling_factor
    end

    def update(frame_time, keys : Keys, mouse : Mouse, shootables : Array(HealthObj), bumpables : Array(HealthObj))
      super(frame_time)

      animations.update(frame_time)

      thrusters[:animations].each do |dir, a|
        a.update(frame_time)
      end

      mouse_rotation = mouse.to_rotation(Screen.width / 2, Screen.height / 2)

      update_movement(frame_time, keys, bumpables)
      update_cannon(frame_time, mouse, mouse_rotation, shootables)
      update_super_weapon(frame_time, keys, mouse, mouse_rotation, shootables)
    end

    def update_movement(frame_time, keys : Keys, bumpables : Array(HealthObj))
      dx = 0_f64
      dy = 0_f64
      speed = Speed * Screen.scaling_factor * frame_time

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

      move(dx, dy)

      if bumped?(bumpables)
        move(-dx * BumpBackFactor, -dy * BumpBackFactor)
      end
    end

    def bumped?(bumpables : Array(HealthObj))
      bumpables.any? do |bumpable|
        if hit?(bumpable.hit_circle)
          hit(bumpable.collision_damage)
        end
      end
    end

    def update_cannon(frame_time, mouse : Mouse, mouse_rotation : Float64, shootables : Array(HealthObj))
      cannon.update(frame_time, x, y, mouse_rotation)
      update_firing(mouse, mouse_rotation)
      lasers.each(&.update(frame_time, shootables))
      lasers.select(&.remove?).each do |laser|
        lasers.delete(laser)
      end
    end

    def update_super_weapon(frame_time, keys : Keys, mouse : Mouse, mouse_rotation : Float64, shootables : Array(HealthObj))
      pulse.update(frame_time, super_weapon == pulse, super_weapon_timer.done?, x, y, shootables)
      beam.update(frame_time, super_weapon == beam, super_weapon_timer.done?, x, y, mouse_rotation, shootables)

      if !super_weapon_timer.started? || super_weapon_timer.done?
        super_weapon_timer.restart
      end

      if keys.just_pressed?(Keys::Q)
        prev_super_weapon
      elsif keys.just_pressed?(Keys::E)
        next_super_weapon
      end
    end

    def prev_super_weapon
      if index = super_weapons.index(super_weapon)
        index -= 1
        index = super_weapons.size - 1 if index < 0

        @super_weapon = super_weapons[index]
      end
    end

    def next_super_weapon
      if index = super_weapons.index(super_weapon)
        index += 1
        index = 0 if index > super_weapons.size - 1

        @super_weapon = super_weapons[index]
      end
    end

    def update_firing(mouse : Mouse, mouse_rotation : Float64)
      if mouse.pressed?(Mouse::Left)
        if fire_timer.started?
          if fire_timer.done?
            fire(mouse_rotation)

            fire_timer.restart
          end
        else
          fire_timer.start

          fire(mouse_rotation)
        end
      else
        fire_timer.stop
      end
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y, color: health_color)

      [:top, :left, :bottom, :right].each do |dir|
        if thrusters[:playing].includes?(dir)
          draw_x = x
          draw_y = y

          case dir
          when :top
            draw_y = draw_y - size / 2 - ThrusterSize * Screen.scaling_factor / 2
          when :left
            draw_x = draw_x - size / 2 - ThrusterSize * Screen.scaling_factor / 2
          when :bottom
            draw_y = draw_y + size / 2 + ThrusterSize * Screen.scaling_factor / 2
          when :right
            draw_x = draw_x + size / 2 + ThrusterSize * Screen.scaling_factor / 2
          end

          thrusters[:animations][dir].draw(window, draw_x, draw_y)
        end
      end

      lasers.each(&.draw(window))
      super_weapons.each(&.draw(window))
      cannon.draw(window)
    end

    def fire(mouse_rotation : Float64)
      @lasers << Laser.new(x, y, mouse_rotation)
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
