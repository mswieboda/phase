require "./font"

module Phase
  class HUD
    getter ship : Ship
    getter text

    Margin = 10

    TextColor = SF::Color::Green

    def initialize(ship : Ship)
      @ship = ship

      @text = SF::Text.new("", Font.default, 24)
      @text.fill_color = TextColor
      @text.position = {Margin, Margin}
    end

    def update(frame_time)
      percent = (ship.super_weapon_timer.percent * 100).to_i
      @text.string = "super weapon: #{percent}%"
    end

    def draw(window : SF::RenderWindow)
      window.draw(text)
    end
  end
end
