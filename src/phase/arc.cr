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
    #       currently just intersection of outer circle
    def intersects?(box : Box)
      dist_x = (x - box.x - box.width / 2).abs
      dist_y = (y - box.y - box.height / 2).abs

      return false if dist_x > box.width / 2 + outer_radius
      return false if dist_y > box.height / 2 + outer_radius
      return true if dist_x <= box.width / 2
      return true if dist_y <= box.height / 2

      dx = dist_x - box.width / 2
      dy = dist_y - box.height / 2

      return false unless dx * dx + dy * dy <= outer_radius * outer_radius

      # TODO: check if it's entirely outside of the inner circle
      true

      # TODO: check to make sure all points are outside the inner circle
      #       check the distance from circle center to point, is >= inner radius
    end

    def intersects?(circle : Circle)
      center_dist_x = x - circle.x
      center_dist_y = y - circle.y

      dist = Math.sqrt(center_dist_x * center_dist_x + center_dist_y * center_dist_y)

      return false if dist - circle.radius > outer_radius

      # entirely inside the inner circle (bordering edge is not inside)
      dist + circle.radius >= inner_radius
    end
  end
end
