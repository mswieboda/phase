require "./enemy"
require "./star_base"

module Phase
  class EnemyShip < Enemy
    getter fire_timer : Timer
    getter fire_sound
    getter laser : Laser?

    Sheet = "./assets/enemy.png"
    ShootDistance = 1280
    LaserHeight = 16
    DebugShootBox = false
    FireDuration = 500.milliseconds
    FireSound = SF::SoundBuffer.from_file("./assets/pew.wav")
    ScoreValue = 3

    def initialize(x = 0, y = 0)
      super(x, y)

      @fire_timer = Timer.new(FireDuration)
      @fire_sound = SF::Sound.new(FireSound)
      @laser = nil
    end

    def self.sheet
      Sheet
    end

    def self.score_value
      ScoreValue
    end

    def shoot_box
      Box.new(x, y, ShootDistance, LaserHeight, rotation, x, y + LaserHeight / 2)
    end

    def update(frame_time, objs : Array(HealthObj))
      super

      @laser = nil

      shoot_check(objs)
    end

    def draw(window : SF::RenderWindow)
      super

      draw_shoot_box(window)
    end

    def draw_shoot_box(window : SF::RenderWindow)
      return unless DebugShootBox

      sb = shoot_box
      rect = SF::RectangleShape.new({sb.width, sb.height})
      rect.fill_color = SF.color(0, 0, 0, 0)
      rect.outline_thickness = 2
      rect.outline_color = SF.color(255, 0, 255)
      rect.origin = {0, LaserHeight / 2}
      rect.position = {sb.x, sb.y}
      rect.rotation = sb.rotation

      window.draw(rect)
    end

    def shoot_check(objs)
      objs.each do |obj|
        next if obj.is_a?(Enemy)
        next unless obj.hit_circle.intersects?(shoot_box)

        if fire_timer.started?
          if fire_timer.done?
            fire

            fire_timer.restart
          end
        else
          fire_timer.start

          fire
        end

        return
      end

      fire_timer.stop
    end

    def fire
      fire_sound.pitch = rand(0.5) + 0.75
      fire_sound.play

      @laser = Laser.new(x, y, rotation, from_enemy: true)
    end
  end
end
