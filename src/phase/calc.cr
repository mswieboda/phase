module Phase
  class Calc
    def self.distance(x, y, x2, y2)
      dx = x2 - x
      dy = y2 - y

      Math.sqrt(dx * dx + dy * dy)
    end

    def self.shortest_delta(target_rotation, rotation)
      delta = target_rotation - rotation

      if delta > 180
        delta - 360
      elsif delta < -180
        delta + 360
      else
        delta
      end
    end
  end
end
