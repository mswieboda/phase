module Phase
  class Circle
    property x : Float64
    property y : Float64
    property radius : Int32

    def initialize(x = 0_f32, y = 0_f32, radius = 1)
      @x = x
      @y = y
      @radius = radius
    end

    def intersects?(box : Box)
      dist_x = (x - box.x - box.width / 2).abs
      dist_y = (y - box.y - box.height / 2).abs

      return false if dist_x > box.width / 2 + radius
      return false if dist_y > box.height / 2 + radius
      return true if dist_x <= box.width / 2
      return true if dist_y <= box.height / 2

      dx = dist_x - box.width / 2
      dy = dist_y - box.height / 2

      dx * dx + dy * dy <= radius * radius
    end

    def intersects?(circle : Circle)
      center_dist_x = x - circle.x
      center_dist_y = y - circle.y

      dist = Math.sqrt(center_dist_x * center_dist_x + center_dist_y * center_dist_y)

      dist - circle.radius <= radius
    end
  end
end
