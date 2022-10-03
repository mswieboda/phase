require "./font"

module Phase
  class HUD
    getter ship : Ship
    getter text
    getter super_percent_text : String
    getter score_text : String
    getter? game_over
    getter game_over_message : String?

    Margin = 10

    TextColor = SF::Color::Green
    TextSelectedColor = SF::Color::White

    def initialize(ship : Ship)
      @ship = ship

      @text = SF::Text.new("", Font.default, (24 * Screen.scaling_factor).to_i)
      @text.fill_color = SF::Color::Green
      @text.position = {margin, margin}

      @super_percent_text = "super: 0%"
      @score_text = "score: 0"
      @game_over = false
      @game_over_message = nil
    end

    def self.margin
      Margin * Screen.scaling_factor
    end

    def margin
      self.class.margin
    end

    def update(frame_time, score, game_over, game_over_message)
      @game_over = game_over
      @game_over_message = game_over_message

      @score_text = "score: #{score}"

      percent = (ship.super_weapon_timer.percent * 100).to_i
      @super_percent_text = "super: #{percent}%"
    end

    def draw(window : SF::RenderWindow)
      @text.position = {margin, margin}

      draw_score(window)
      draw_super_percent(window)
      draw_super_weapons(window)

      draw_game_over(window) if game_over?
    end

    def draw_score(window)
      y = text.global_bounds.top + text.global_bounds.height

      text.string = score_text
      text.position = {margin, y}

      window.draw(text)
    end

    def draw_super_percent(window)
      y = text.global_bounds.top + text.global_bounds.height + margin

      text.string = super_percent_text
      text.position = {margin, y}

      window.draw(text)
    end

    def draw_super_weapons(window)
      y = text.global_bounds.top + text.global_bounds.height + margin

      ship.super_weapons.each_with_index do |weapon, index|
        text.string = weapon.name
        y += text.global_bounds.height + margin
        text.position = {margin, y}
        selected = ship.super_weapon.name == weapon.name
        text.fill_color = selected ? TextSelectedColor : TextColor

        window.draw(text)
      end
    end

    def draw_game_over(window)
      x = Screen.width / 2
      y = Screen.height / 4

      # header
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

      y += header.global_bounds.height + margin * 5

      # score
      score = SF::Text.new(score_text, Font.default, (36 * Screen.scaling_factor).to_i)
      score.fill_color = SF::Color::Green

      dx = x - score.global_bounds.width / 2

      score.position = {dx, y}

      rect = SF::RectangleShape.new({score.global_bounds.width + margin * 2, score.global_bounds.height + margin * 2})
      rect.fill_color = SF::Color::Black
      rect.position = {dx - margin, y - margin}

      window.draw(rect)
      window.draw(score)

      y += score.global_bounds.height + margin * 7

      # game over message
      if message_text = game_over_message
        message = SF::Text.new(message_text, Font.default, (26 * Screen.scaling_factor).to_i)
        message.fill_color = SF::Color::Green

        dx = x - message.global_bounds.width / 2

        message.position = {dx, y}

        rect = SF::RectangleShape.new({message.global_bounds.width + margin * 2, message.global_bounds.height + margin * 2})
        rect.fill_color = SF::Color::Black
        rect.position = {dx - margin, y - margin}

        window.draw(rect)
        window.draw(message)

        y += message.global_bounds.height + margin * 3
      end

      # action
      action = SF::Text.new("press enter to restart", Font.default, (32 * Screen.scaling_factor).to_i)
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
