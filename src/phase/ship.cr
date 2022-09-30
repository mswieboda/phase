module Phase
  class Ship
    getter x : Float64
    getter y : Float64
    getter animations

    Speed = 666
    Sheet = "./assets/ship.png"

    def initialize(x = 0, y = 0)
      # sprite size
      size = 128
      @x = x
      @y = y

      # init animations
      fps = 60

      # idle
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(Sheet, 0, 0, size, size)

      @animations = GSF::Animations.new(:idle, idle)
    end

    def update(frame_time, keys : Keys, mouse : Mouse)
      animations.update(frame_time)

      update_movement(frame_time, keys)
      update_turret(frame_time, mouse)
    end

    def update_movement(frame_time, keys : Keys)
      dx = 0_f64
      dy = 0_f64
      speed = Speed * frame_time

      dy -= speed if keys.pressed?(Keys::W)
      dx -= speed if keys.pressed?(Keys::A)
      dy += speed if keys.pressed?(Keys::S)
      dx += speed if keys.pressed?(Keys::D)

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
    end

    def move(dx : Float64, dy : Float64)
      @x += dx
      @y += dy
    end
  end
end
