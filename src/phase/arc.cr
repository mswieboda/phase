module Phase
  class Arc
    property x : Float64
    property y : Float64
    property inner_radius : Int32
    property outer_radius : Int32

    def initialize(x = 0_f32, y = 0_f32, inner_radius = 1, outer_radius = 1)
      @x = x
      @y = y
      @inner_radius = inner_radius
      @outer_radius = outer_radius
    end

    # TODO: doesn't account for inner_radius
    #       currently just intersection of circle with outer_radius
    def intersects?(box : Box)
      dist_x = (x - box.x - box.width / 2).abs
      dist_y = (y - box.y - box.height / 2).abs

      return false if dist_x > box.width / 2 + outer_radius
      return false if dist_y > box.height / 2 + outer_radius
      return true if dist_x <= box.width / 2
      return true if dist_y <= box.height / 2

      dx = dist_x - box.width / 2
      dy = dist_y - box.height / 2

      dx * dx + dy * dy <= outer_radius * outer_radius
    end
  end
end
