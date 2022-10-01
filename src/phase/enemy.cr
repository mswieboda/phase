module Phase
  class Enemy
    getter x : Float64
    getter y : Float64
    getter animations
    getter? hit

    Sheet = "./assets/enemy.png"
    Size = 128
    HitColor = SF::Color::Red

    def initialize(x = 0, y = 0)
      @x = x
      @y = y

      # init animations
      fps = 60

      # idle
      idle_size = size
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(Sheet, 0, 0, idle_size, idle_size)

      @animations = GSF::Animations.new(:idle, idle)
      @hit = false
    end

    def self.size
      Size
    end

    def size
      self.class.size
    end

    def hit_box
      Box.new(x: x - size / 2, y: y - size / 2, width: size, height: size)
    end

    def hit!
      @hit = true
    end

    def update(frame_time)
      @hit = false
      animations.update(frame_time)
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y, color: hit? ? HitColor : SF::Color::White)
    end

    def move(dx : Float64, dy : Float64)
      @x += dx
      @y += dy
    end
  end
end
