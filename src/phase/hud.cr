require "./font"

module Phase
  class HUD
    getter ship : Ship
    getter text
    getter super_weapon_text
    getter? game_over
    getter game_over_message : String?

    Margin = 10

    TextColor = SF::Color::White
    TextSelectedColor = SF::Color::Green

    def initialize(ship : Ship)
      @ship = ship

      @text = SF::Text.new("", Font.default, (24 * Screen.scaling_factor).to_i)
      @text.fill_color = SF::Color::Green
      @text.position = {margin, margin}

      y = @text.global_bounds.top + @text.global_bounds.height + margin

      @super_weapon_text = SF::Text.new("", Font.default, (24 * Screen.scaling_factor).to_i)
      @super_weapon_text.fill_color = TextColor
      @super_weapon_text.position = {margin, y}

      @game_over = false
      @game_over_message = nil
    end

    def self.margin
      Margin * Screen.scaling_factor
    end

    def margin
      self.class.margin
    end

    def update(frame_time, game_over, game_over_message)
      @game_over = game_over
      @game_over_message = game_over_message

      percent = (ship.super_weapon_timer.percent * 100).to_i
      @text.string = "super weapon: #{percent}%"
    end

    def draw(window : SF::RenderWindow)
      window.draw(text)
      draw_super_weapons(window)

      draw_game_over(window) if game_over?
    end

    def draw_super_weapons(window)
      y = @text.global_bounds.top + @text.global_bounds.height + margin

      ship.super_weapons.each_with_index do |weapon, index|
        super_weapon_text.string = weapon.name
        y += super_weapon_text.global_bounds.height + margin
        super_weapon_text.position = {margin, y}
        selected = ship.super_weapon.name == weapon.name
        super_weapon_text.fill_color = selected ? TextSelectedColor : TextColor

        window.draw(super_weapon_text)
      end
    end

    def draw_game_over(window)
      x = Screen.width / 2
      y = Screen.height / 3

      header = SF::Text.new("Game Over", Font.default, (60 * Screen.scaling_factor).to_i)
      header.fill_color = SF::Color::Green

      dx = x - header.global_bounds.width / 2
      y -= header.global_bounds.height / 2

      header.position = {dx, y}

      rect = SF::RectangleShape.new({header.global_bounds.width + margin * 2, header.global_bounds.height + margin * 2})
      rect.fill_color = SF::Color::Black
      rect.position = {dx - margin, y - margin}

      window.draw(rect)
      window.draw(header)

      y += header.global_bounds.height + margin * 4

      if message_text = game_over_message
        message = SF::Text.new(message_text, Font.default, (36 * Screen.scaling_factor).to_i)
        message.fill_color = SF::Color::Green

        dx = x - message.global_bounds.width / 2

        message.position = {dx, y}

        rect = SF::RectangleShape.new({message.global_bounds.width + margin * 2, message.global_bounds.height + margin * 2})
        rect.fill_color = SF::Color::Black
        rect.position = {dx - margin, y - margin}

        window.draw(rect)
        window.draw(message)

        y += message.global_bounds.height + margin * 2
      end

      action = SF::Text.new("press enter to restart", Font.default, (36 * Screen.scaling_factor).to_i)
      action.fill_color = SF::Color::Green

      dx = x - action.global_bounds.width / 2

      action.position = {dx, y}

      rect = SF::RectangleShape.new({action.global_bounds.width + margin * 2, action.global_bounds.height + margin * 2})
      rect.fill_color = SF::Color::Black
      rect.position = {dx - margin, y - margin}

      window.draw(rect)
      window.draw(action)
    end
  end
end
