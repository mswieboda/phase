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
      return intersects_rotated?(box) if box.rotated?

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

    def intersects_rotated?(box : Box)
      # rotate circle back from box's angle
      theta = -box.rotation * Math::PI / 180
      cx = Math.cos(theta) * (x - box.origin_x) - Math.sin(theta) * (y - box.origin_y) + box.origin_x
      cy = Math.sin(theta) * (x - box.origin_x) + Math.cos(theta) * (y - box.origin_y) + box.origin_y
      circle = Circle.new(cx, cy, radius)

      # find closest point in the box to the center of the (backwards rotated) circle
      closest_x = circle.x
      closest_y = circle.y

      if circle.x < box.x
        closest_x = box.x
      elsif circle.x > box.x + box.width
        closest_x = box.x + box.width
      end

      if circle.y < box.y
        closest_y = box.y
      elsif circle.y > box.y + box.height
        closest_y = box.y + box.height
      end

      # determine collision
      dx = closest_x - circle.x
      dy = closest_y - circle.y
      distance = Math.sqrt(dx * dx + dy * dy)

      distance < radius
    end

    def intersects?(circle : Circle)
      center_dist_x = x - circle.x
      center_dist_y = y - circle.y

      dist = Math.sqrt(center_dist_x * center_dist_x + center_dist_y * center_dist_y)

      dist - circle.radius <= radius
    end
  end
end
