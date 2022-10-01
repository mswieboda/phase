require "./super_weapon"
require "./box"
require "./arc"

module Phase
  class Pulse < SuperWeapon
    getter x : Float64
    getter y : Float64
    getter animations

    Sheet = "./assets/pulse.png"
    Duration = 10.seconds

    OuterRadii = [64, 128, 192, 256, 320, 320, 320]
    InnerRadii = [0, 64, 128, 192, 256, 288, 304]
    DebugHitBox = false
    Damage = 10

    def initialize(x = 0, y = 0)
      super("pulse")

      @x = x
      @y = y

      # init animations
      fps = 60

      # fire
      pulse_size = 640
      pulse_frames = 7
      pulse = GSF::Animation.new((fps / 10).to_i, loops: false)

      pulse_frames.times do |index|
        pulse.add(Sheet, index * pulse_size, 0, pulse_size, pulse_size)
      end

      @animations = GSF::Animations.new(:pulse, pulse)
      @animations.play(:pulse)
    end

    def update(frame_time, current : Bool, timer_done : Bool, x : Float64, y : Float64, enemies : Array(Enemy))
      move(x, y) unless firing?

      animations.update(frame_time)

      @firing = false if firing? && animations.done?

      if current && timer_done
        animations.play(:pulse)
        @firing = true
      end

      if firing?
        enemies.each do |enemy|
          enemy.hit(Damage) if hit?(enemy.hit_circle)
        end
      end
    end

    def draw(window : SF::RenderWindow)
      return unless firing?

      animations.draw(window, x, y)
      draw_hit_arc(window)
    end

    def draw_hit_arc(window : SF::RenderWindow)
      return unless DebugHitBox

      ha = hit_arc

      inner = SF::CircleShape.new(ha.inner_radius)
      inner.fill_color = SF.color(0, 0, 0, 0)
      inner.outline_thickness = 2
      inner.outline_color = SF.color(250, 150, 100)
      inner.origin = {ha.inner_radius, ha.inner_radius}
      inner.position = {ha.x, ha.y}

      outer = SF::CircleShape.new(ha.outer_radius)
      outer.fill_color = SF.color(0, 0, 0, 0)
      outer.outline_thickness = 2
      outer.outline_color = SF.color(250, 150, 100)
      outer.origin = {ha.outer_radius, ha.outer_radius}
      outer.position = {ha.x, ha.y}

      window.draw(inner)
      window.draw(outer)
    end

    def move(x : Float64, y : Float64)
      @x = x
      @y = y
    end

    def radii
      display_frame = animations.display_frame

      {
        outer: OuterRadii[display_frame],
        inner: InnerRadii[display_frame]
      }
    end

    def hit_arc
      Arc.new(x, y, radii[:inner], radii[:outer])
    end

    def hit?(circle : Circle) : Bool
      hit_arc.intersects?(circle)
    end
  end
end
