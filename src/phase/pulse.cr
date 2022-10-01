module Phase
  class Pulse
    getter x : Float64
    getter y : Float64
    getter animations
    getter timer : GSF::Timer
    getter? firing

    Sheet = "./assets/pulse.png"
    Duration = 10.seconds

    Sizes = [128, 256, 384, 512, 640]

    def initialize(x = 0, y = 0)
      @x = x
      @y = y

      # init animations
      fps = 60

      # fire
      pulse_size = 640
      pulse_frames = 5
      pulse = GSF::Animation.new((fps / 10).to_i, loops: false)

      pulse_frames.times do |index|
        pulse.add(Sheet, index * pulse_size, 0, pulse_size, pulse_size)
      end

      # add in extra frames at end
      pulse.add(Sheet, 4 * pulse_size, 0, pulse_size, pulse_size)
      pulse.add(Sheet, 4 * pulse_size, 0, pulse_size, pulse_size)

      @animations = GSF::Animations.new(:pulse, pulse)
      @animations.play(:pulse)
      @timer = GSF::Timer.new(Duration)
      @firing = true
    end

    def update(frame_time, x : Float64, y : Float64)
      move(x, y)

      animations.update(frame_time)

      update_pulse(frame_time)
    end

    def update_pulse(frame_time)
      @firing = false if firing? && animations.done?

      if timer.done?
        timer.restart

        animations.play(:pulse)
        @firing = true
      else
        timer.start unless timer.started?
      end
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y) if firing?
    end

    def move(dx : Float64, dy : Float64)
      @x = dx
      @y = dy
    end
  end
end
