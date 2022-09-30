module Phase
  class Pulse
    getter x : Float64
    getter y : Float64
    getter animations
    getter timer : GSF::Timer
    getter? firing

    Sheet = "./assets/pulse.png"
    Duration = 10.seconds

    def initialize(x = 0, y = 0)
      # sprite size
      size = 640
      @x = x
      @y = y

      # init animations
      fps = 60

      # fire
      fire_frames = 5
      fire = GSF::Animation.new((fps / 10).to_i, loops: false)

      fire_frames.times do |index|
        fire.add(Sheet, index * size, 0, size, size)
      end

      # add in extra frames at end
      fire.add(Sheet, 4 * size, 0, size, size)
      fire.add(Sheet, 4 * size, 0, size, size)

      @animations = GSF::Animations.new(:fire, fire)
      @animations.play(:fire)
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

        animations.play(:fire)
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
