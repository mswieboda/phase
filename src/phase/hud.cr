require "./font"

module Phase
  class HUD
    getter ship : Ship
    getter text

    Margin = 10

    TextColor = SF::Color::Green

    def initialize(ship : Ship)
      @ship = ship

      @text = SF::Text.new("phase pulse:", Font.default, 24)
      @text.fill_color = TextColor
      @text.position = {Margin, Margin}
    end

    def update(frame_time)
      percent = (ship.pulse.timer.percent * 100).to_i
      @text.string = "phase pulse: #{percent}%"
    end

    def draw(window : SF::RenderWindow)
      window.draw(text)
    end
  end
end
