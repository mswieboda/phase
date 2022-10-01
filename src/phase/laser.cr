module Phase
  class Laser
    getter x : Float64
    getter y : Float64
    getter rotation : Float64
    getter dx : Float64
    getter dy : Float64
    getter animations

    Speed = 10
    Sheet = "./assets/laser.png"
    Width = 48
    Height = 16
    HitRadius = 16

    def initialize(x = 0_f32, y = 0_f32, rotation = 0)
      @x = x
      @y = y
      @rotation = rotation

      speed = Speed
      theta = rotation * Math::PI / 180
      @dx = speed * Math.cos(theta)
      @dy = speed * Math.sin(theta)

      puts ">>> Laser rotation: #{rotation} (dx, dy): (#{@dx}, #{@dy})"

      # animations
      fps = 60
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(Sheet, 0, 0, Width, Height, rotation: rotation)

      @animations = GSF::Animations.new(:idle, idle)
    end

    def update(frame_time)
      animations.update(frame_time)

      update_movement(frame_time)
    end

    def update_movement(frame_time)
      @x += dx
      @y += dy
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y)
    end
  end
end
