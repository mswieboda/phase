module Phase
  class Box
    property x : Float64
    property y : Float64
    property width : Int32
    property height : Int32
    property rotation : Float64
    property origin_x : Float64
    property origin_y : Float64

    def initialize(x = 0_f32, y = 0_f32, width = 1, height = 1, rotation = 0, origin_x = 0, origin_y = 0)
      @x = x
      @y = y
      @width = width
      @height = height
      @rotation = rotation
      @origin_x = origin_x
      @origin_y = origin_y
    end

    def rotated?
      rotation != 0
    end
  end
end
