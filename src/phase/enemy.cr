require "./circle"

module Phase
  class Enemy
    getter x : Float64
    getter y : Float64
    getter animations
    getter? hit

    Sheet = "./assets/enemy.png"
    Size = 128
    HitRadius = 64
    HitColor = SF::Color::Red
    DebugHitBox = false

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

    def self.hit_radius
      HitRadius
    end

    def hit_radius
      self.class.hit_radius
    end

    def hit_circle
      Circle.new(x: x, y: y, radius: hit_radius)
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
      draw_hit_circle(window)
    end

    def draw_hit_circle(window : SF::RenderWindow)
      return unless DebugHitBox

      hc = hit_circle
      circle = SF::CircleShape.new(hc.radius)
      circle.fill_color = SF.color(0, 0, 0, 0)
      circle.outline_thickness = 2
      circle.outline_color = SF.color(250, 150, 100)
      circle.origin = {hc.radius, hc.radius}
      circle.position = {hc.x, hc.y}

      window.draw(circle)
    end

    def move(dx : Float64, dy : Float64)
      @x += dx
      @y += dy
    end
  end
end
