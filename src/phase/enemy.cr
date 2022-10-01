module Phase
  class Enemy
    getter x : Float64
    getter y : Float64
    getter animations

    Sheet = "./assets/ship.png"

    def initialize(x = 0, y = 0)
      @x = x
      @y = y

      # init animations
      fps = 60

      # idle
      idle_size = 128
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(Sheet, 0, 0, idle_size, idle_size)

      @animations = GSF::Animations.new(:idle, idle)
    end

    def update(frame_time)
      animations.update(frame_time)
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
