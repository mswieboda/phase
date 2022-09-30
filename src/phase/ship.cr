module Phase
  class Ship
    getter x : Int32
    getter y : Int32
    getter animations

    Speed = 15
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

    def update(frame_time, keys : Keys)
      animations.update(frame_time)

      update_movement(keys)
    end

    def update_movement(keys : Keys)
      dx = 0
      dy = 0

      dy -= Speed if keys.pressed?(Keys::W)
      dx -= Speed if keys.pressed?(Keys::A)
      dy += Speed if keys.pressed?(Keys::S)
      dx += Speed if keys.pressed?(Keys::D)

      move(dx, dy) if y + dy > 0 && x + dy > 0
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y)
    end

    def move(dx : Int32, dy : Int32)
      @x += dx
      @y += dy
    end
  end
end
