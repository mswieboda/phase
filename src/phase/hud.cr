require "./font"

module Phase
  class HUD
    getter ship : Ship
    getter text
    getter super_weapon_text

    Margin = 10

    TextColor = SF::Color::White
    TextSelectedColor = SF::Color::Green

    def initialize(ship : Ship)
      @ship = ship

      @text = SF::Text.new("", Font.default, 24)
      @text.fill_color = SF::Color::Green
      @text.position = {Margin, Margin}

      y = @text.global_bounds.top + @text.global_bounds.height + Margin

      @super_weapon_text = SF::Text.new("", Font.default, 24)
      @super_weapon_text.fill_color = TextColor
      @super_weapon_text.position = {Margin, y}
    end

    def update(frame_time)
      percent = (ship.super_weapon_timer.percent * 100).to_i
      @text.string = "super weapon: #{percent}%"
    end

    def draw(window : SF::RenderWindow)
      window.draw(text)
      draw_super_weapons(window)
    end

    def draw_super_weapons(window)
      y = @text.global_bounds.top + @text.global_bounds.height + Margin

      ship.super_weapons.each_with_index do |weapon, index|
        super_weapon_text.string = weapon.name
        y += super_weapon_text.global_bounds.height + Margin
        super_weapon_text.position = {Margin, y}
        selected = ship.super_weapon.name == weapon.name
        super_weapon_text.fill_color = selected ? TextSelectedColor : TextColor

        window.draw(super_weapon_text)
      end
    end
  end
end
