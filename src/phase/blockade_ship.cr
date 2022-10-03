require "./health_obj"
require "./blockade_cannon"

module Phase
  class BlockadeShip < HealthObj
    getter sprite : SF::Sprite
    getter cannon : BlockadeCannon
    getter cannon_rotation : Float64
    getter fire_timer : Timer
    getter fire_sound
    getter laser : Laser?

    Sprite = "./assets/blockade_ship.png"
    SpriteWidth = 384
    SpriteHeight = 256
    HitRadius = 160
    MaxHealth = 1500
    CannonOffsetX = 48
    # CannonOffsetY = -8
    CannonRadius = 1000
    FireDuration = 100.milliseconds
    FireSound = SF::SoundBuffer.from_file("./assets/pew.wav")

    def initialize(x = 0, y = 0)
      super(x, y)

      # sprite
      texture = SF::Texture.from_file(Sprite, SF::IntRect.new(0, 0, SpriteWidth, SpriteHeight))
      @sprite = SF::Sprite.new(texture)
      @sprite.position = {x, y}
      @sprite.origin = texture.size / 2.0

      @cannon = BlockadeCannon.new(cannon_x, cannon_y)
      @cannon_rotation = 0
      @fire_timer = Timer.new(FireDuration)
      @fire_sound = SF::Sound.new(FireSound)
      @laser = nil

      @remove = false
    end

    def self.hit_radius
      HitRadius
    end

    def self.max_health
      MaxHealth
    end

    def cannon_x
      x + CannonOffsetX
    end

    def cannon_y
      y #+ CannonOffsetY
    end

    def update(frame_time, objs : Array(HealthObj))
      super

      update_firing(frame_time, objs)
      cannon.update(frame_time, cannon_x, cannon_y, cannon_rotation)
    end

    def draw(window : SF::RenderWindow)
      sprite.position = {x, y}
      sprite.color = health_color

      window.draw(sprite)
      draw_hit_circle(window)

      cannon.draw(window)
    end

    def static?
      true
    end

    def bump(dx, dy, bumped_by, objs)
      bumped_by.move(-dx, -dy)
    end

    def cannon_hit_circle
      Circle.new(x: cannon_x, y: cannon_y, radius: CannonRadius)
    end

    def update_firing(frame_time, objs : Array(HealthObj))
      objs.each do |obj|
        next unless obj.is_a?(Enemy)
        next if obj.is_a?(EnemyCarrier)
        next unless obj.hit?(cannon_hit_circle)

        @cannon_rotation = obj.rotation_from(cannon_x, cannon_y)

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

      @laser = Laser.new(cannon_x, cannon_y, cannon_rotation)
    end
  end
end
