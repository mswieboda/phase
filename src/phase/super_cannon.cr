require "./super_weapon"
require "./box"
require "./arc"

module Phase
  class SuperCannon < SuperWeapon
    getter distance
    getter duration_timer
    getter sprite
    getter sprite_tip

    SpriteSegment = "./assets/super_laser_segment.png"
    SpriteTip = "./assets/super_laser_tip.png"
    Damage = 10
    Duration = 1337.milliseconds
    MaxDistance = 1337
    SegmentWidth = 8
    SegmentHeight = 32
    Segments = (MaxDistance / SegmentHeight).to_i

    delegate rotation, to: sprite

    def initialize(x = 0, y = 0, rotation = 0_f64)
      super()

      @distance = MaxDistance # TODO: start at 0_f64 and grow to MaxDistance quickly using another timer?
      @duration_timer = Timer.new(Duration)

      # sprite
      texture = SF::Texture.from_file(SpriteSegment, SF::IntRect.new(0, 0, SegmentWidth, SegmentHeight))
      texture.repeated = true

      @sprite = SF::Sprite.new(texture, SF::IntRect.new(0, 0, @distance, SegmentHeight))
      @sprite.position = {x, y}
      @sprite.origin = {0, texture.size.y / 2.0}
      @sprite.rotation = rotation

      texture_tip = SF::Texture.from_file(SpriteTip, SF::IntRect.new(0, 0, SegmentWidth, SegmentHeight))

      @sprite_tip = SF::Sprite.new(texture_tip)
      @sprite_tip.position = {x, y}
      @sprite_tip.origin = {-@distance, texture.size.y / 2.0}
      @sprite_tip.rotation = rotation
    end

    def update(frame_time, timer_done : Bool, x : Float64, y : Float64, rotation : Float64, enemies : Array(Enemy))
      move(x, y, rotation)

      @firing = false if firing? && duration_timer.done?

      if timer_done
        duration_timer.restart

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

      window.draw(sprite)
      window.draw(sprite_tip)
    end

    def hit?(circle : Circle) : Bool
      # TODO: detect collision with rotated box and circle
      false
    end

    def move(x, y, rotation)
      sprite.position = {x, y}
      sprite.rotation = rotation
      sprite_tip.position = {x, y}
      sprite_tip.rotation = rotation
    end
  end
end
