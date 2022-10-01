require "./box"
require "./arc"

module Phase
  class Pulse
    getter x : Float64
    getter y : Float64
    getter animations
    getter timer : GSF::Timer
    getter? firing

    Sheet = "./assets/pulse.png"
    Duration = 1.seconds

    OuterRadii = [64, 128, 192, 256, 320, 320, 320]
    InnerRadii = [0, 32, 64, 128, 192, 256, 288]

    def initialize(x = 0, y = 0)
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
      @timer = GSF::Timer.new(Duration)
      @firing = true
    end

    def update(frame_time, x : Float64, y : Float64, enemies : Array(Enemy))
      move(x, y)

      animations.update(frame_time)

      update_pulse(frame_time, enemies)
    end

    def update_pulse(frame_time, enemies : Array(Enemy))
      @firing = false if firing? && animations.done?

      if timer.done?
        timer.restart

        animations.play(:pulse)
        @firing = true
      else
        timer.start unless timer.started?
      end

      enemies.each do |enemy|
        enemy.hit! if hit?(enemy.hit_box)
      end
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y) if firing?
    end

    def move(dx : Float64, dy : Float64)
      @x = dx
      @y = dy
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

    def hit?(box : Box)
      return false unless firing?

      hit_arc.intersects?(box)
    end
  end
end
