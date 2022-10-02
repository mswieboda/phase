require "./health_obj"

module Phase
  class Enemy < HealthObj
    getter animations
    getter? hit

    Sheet = "./assets/enemy.png"
    SpriteSize = 128
    HitRadius = 64
    HitColor = SF::Color::Red

    def initialize(x = 0, y = 0, sheet = Sheet)
      super(x, y)

      # init animations
      fps = 60

      # idle
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(sheet, 0, 0, SpriteSize, SpriteSize)

      @animations = GSF::Animations.new(:idle, idle)
      @hit = false
    end

    def self.hit_radius
      HitRadius * Screen.scaling_factor
    end

    def hit(damage : Int32)
      @hit = true

      @health -= damage

      if @health <= 0
        @health = 0

        explode_remove
      end
    end

    def update(frame_time)
      @hit = false
      animations.update(frame_time)
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y, color: hit? ? HitColor : SF::Color::White)
      draw_hit_circle(window)
    end

    def move(dx : Float64, dy : Float64)
      @x += dx
      @y += dy
    end

    def explode_remove
      @remove = true
    end
  end
end
