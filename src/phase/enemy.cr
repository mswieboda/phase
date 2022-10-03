require "./health_obj"

module Phase
  class Enemy < HealthObj
    getter rotation : Float32
    getter animations

    Sheet = "./assets/enemy.png"
    SpriteSize = 128
    HitRadius = 64
    FacingRotationThreshold = 0.1_f32
    RotationSpeed = 100
    BumpBackFactor = 3
    ScoreValue = 1

    def initialize(x = 0, y = 0, rotation = 0)
      super(x, y)

      @rotation = rotation

      # init animations
      fps = 60

      # idle
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(sheet, 0, 0, sprite_width, sprite_height)

      @animations = GSF::Animations.new(:idle, idle)
    end

    def self.sheet
      Sheet
    end

    def sheet
      self.class.sheet
    end

    def self.sprite_width
      SpriteSize
    end

    def sprite_width
      self.class.sprite_width
    end

    def self.sprite_height
      SpriteSize
    end

    def sprite_height
      self.class.sprite_height
    end

    def self.hit_radius
      HitRadius
    end

    def self.score_value
      ScoreValue
    end

    def score_value
      self.class.score_value
    end

    def update(frame_time, objs : Array(HealthObj))
      super

      animations.update(frame_time)
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y, color: health_color, rotation: rotation)
      draw_hit_circle(window)
    end

    def facing?(target_rotation)
      (Calc.shortest_delta(target_rotation, rotation)).abs < FacingRotationThreshold
    end

    def move_forward(speed, objs : Array(HealthObj))
      theta = rotation * Math::PI / 180
      dx = speed * Math.cos(theta)
      dy = speed * Math.sin(theta)

      move(dx, dy)

      objs.each do |obj|
        if !obj.is_a?(EnemyCarrier) && hit?(obj.hit_circle)
          bx = x - obj.x
          by = y - obj.y
          bx = bx.zero? ? 0 : bx / bx.abs
          by = by.zero? ? 0 : by / by.abs
          bx = (bx * BumpBackFactor).to_f64
          by = (by * BumpBackFactor).to_f64

          move(bx, by)

          unless obj.static?
            obj.bump(bx, by, self, objs)
          end
        end
      end
    end

    def rotate(amount)
      @rotation += amount

      if @rotation >= 360
        @rotation -= 360
      elsif @rotation < 0
        @rotation += 360
      end
    end

    def rotate_towards(target_rotation, rotation_speed)
      delta = Calc.shortest_delta(target_rotation, rotation)
      amount = delta.sign * rotation_speed

      orig_rotation = rotation

      rotate(amount)

      if delta.sign > 0 && amount > delta
        @rotation = target_rotation.to_f32
      elsif delta.sign < 0 && amount < delta
        @rotation = target_rotation.to_f32
      end
    end
  end
end
