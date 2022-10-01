require "./pulse"

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

    Speed = 666
    Sheet = "./assets/ship.png"
    ShipSize = 128
    ThrusterSheet = "./assets/thruster.png"
    ThrusterSize = 32

    def initialize(x = 0, y = 0)
      @x = x
      @y = y
      @pulse = Pulse.new(x, y)

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
      move_factor = 30
      move_top = GSF::Animation.new((fps / move_factor).to_i, loops: false)

      move_frames.times do |index|
        move_top.add(ThrusterSheet, move_size * index, 0, move_size, move_size, flip_vertical: true)
      end

      move_left = GSF::Animation.new((fps / move_factor).to_i, loops: false)

      move_frames.times do |index|
        move_left.add(ThrusterSheet, move_size * index, 0, move_size, move_size, rotation: 90)
      end

      move_bottom = GSF::Animation.new((fps / move_factor).to_i, loops: false)

      move_frames.times do |index|
        move_bottom.add(ThrusterSheet, move_size * index, 0, move_size, move_size)
      end

      move_right = GSF::Animation.new((fps / move_factor).to_i, loops: false)

      move_frames.times do |index|
        move_right.add(ThrusterSheet, move_size * index, 0, move_size, move_size, rotation: -90)
      end

      @thrusters = {
        playing: [] of Symbol,
        animations: {
          top: GSF::Animations.new(:move, move_top),
          left: GSF::Animations.new(:move, move_left),
          bottom: GSF::Animations.new(:move, move_bottom),
          right: GSF::Animations.new(:move, move_right),
        }
      }
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
      update_turret(frame_time, mouse)

      pulse.update(frame_time, x, y, enemies)
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

      if y + dy > 0 && x + dy > 0
        if dx != 0 && dy != 0
          # 45 deg, from sqrt(x^2 + y^2) at 45 deg
          const = 0.70710678118_f64
          dx *= const
          dy *= const
        end

        move(dx, dy)
      end
    end

    def update_turret(frame_time, mouse : Mouse)
      # TODO: rotate turret to the direction of the mouse (instantly)
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

      pulse.draw(window)
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
