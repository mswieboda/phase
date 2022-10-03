require "./super_weapon"
require "./box"
require "./arc"

module Phase
  class Beam < SuperWeapon
    getter distance : Float64
    getter duration_timer
    getter sprite
    getter sprite_tip

    SpriteSegment = "./assets/beam.png"
    SpriteTip = "./assets/beam_tip.png"
    Damage = 3
    Duration = 1337.milliseconds
    MaxDistance = 3333
    SegmentWidth = 8
    SegmentHeight = 32
    Segments = (MaxDistance / SegmentHeight).to_i

    delegate rotation, to: sprite

    def initialize(x = 0, y = 0, rotation = 0_f64)
      super("beam")

      # TODO: start at 0_f64 and grow to MaxDistance quickly using another timer?
      @distance = MaxDistance.to_f64
      @duration_timer = Timer.new(Duration)

      # sprite
      texture = SF::Texture.from_file(SpriteSegment, SF::IntRect.new(0, 0, SegmentWidth, SegmentHeight))
      texture.repeated = true

      @sprite = SF::Sprite.new(texture, SF::IntRect.new(0, 0, @distance.round.to_i, SegmentHeight))
      @sprite.position = {x, y}
      @sprite.origin = {0, texture.size.y / 2.0}
      @sprite.rotation = rotation

      texture_tip = SF::Texture.from_file(SpriteTip, SF::IntRect.new(0, 0, SegmentWidth, SegmentHeight))

      @sprite_tip = SF::Sprite.new(texture_tip)
      @sprite_tip.position = {x, y}
      @sprite_tip.origin = {-@distance, texture.size.y / 2.0}
      @sprite_tip.rotation = rotation
    end

    def height
      SegmentHeight
    end

    def update(frame_time, current : Bool, timer_done : Bool, x : Float64, y : Float64, rotation : Float64, objs : Array(HealthObj))
      move(x, y, rotation)

      @firing = false if firing? && duration_timer.done?

      if current && timer_done
        duration_timer.restart

        @firing = true
      end

      if firing?
        objs.each do |obj|
          next if obj.is_a?(Ship)
          next if obj.is_a?(StarBase)
          next if obj.is_a?(Asteroid)

          obj.hit(Damage) if hit?(obj.hit_circle)
        end
      end
    end

    def draw(window : SF::RenderWindow)
      return unless firing?

      window.draw(sprite)
      window.draw(sprite_tip)
    end

    def hit?(circle : Circle) : Bool
      x = sprite.position.x
      y = sprite.position.y - height / 2
      box = Box.new(x, y, distance, height, rotation, sprite.position.x, sprite.position.y)
      circle.intersects?(box)
    end

    def move(x, y, rotation)
      sprite.position = {x, y}
      sprite.rotation = rotation
      sprite_tip.position = {x, y}
      sprite_tip.rotation = rotation
    end
  end
end
