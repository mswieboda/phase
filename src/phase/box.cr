module Phase
  class Box
    property x : Float64
    property y : Float64
    property width : Int32
    property height : Int32

    def initialize(x = 0_f32, y = 0_f32, width = 1, height = 1)
      @x = x
      @y = y
      @width = width
      @height = height
    end
  end
end
