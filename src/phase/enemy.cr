require "./health_obj"

module Phase
  class Enemy < HealthObj
    getter rotation : Float32
    getter animations

    Sheet = "./assets/enemy.png"
    SpriteSize = 128
    HitRadius = 64

    def initialize(x = 0, y = 0, sheet = Sheet)
      super(x, y)

      @rotation = 0

      # init animations
      fps = 60

      # idle
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(sheet, 0, 0, SpriteSize, SpriteSize)

      @animations = GSF::Animations.new(:idle, idle)
    end

    def self.hit_radius
      HitRadius * Screen.scaling_factor
    end

    def update(frame_time)
      super

      animations.update(frame_time)
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y, color: health_color, rotation: rotation)
      draw_hit_circle(window)
    end

    def move(dx : Float64, dy : Float64)
      @x += dx
      @y += dy
    end
  end
end
