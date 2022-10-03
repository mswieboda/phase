module Phase::Scene
  class Start < GSF::Scene
    getter title : SF::Text
    getter start_scene : Symbol?
    getter? continue
    getter items

    TitleTextColor = SF::Color::Green

    def initialize
      super(:start)

      @start_scene = nil
      @continue = false
      @items = GSF::MenuItems.new(
        font: Font.default,
        labels: ["new", "continue", "exit"],
        size: (36 * Screen.scaling_factor).to_i
      )

      @title = SF::Text.new("phase", Font.default, (60 * Screen.scaling_factor).to_i)
      @title.fill_color = TitleTextColor

      title_x = Screen.width / 2 - @title.global_bounds.width / 2
      title_y = Screen.height / 4 - @title.global_bounds.height / 2

      @title.position = {title_x, title_y}
    end

    def reset
      super

      @start_scene = nil
      @continue = false
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      items.update(frame_time, keys, mouse)

      # TODO: refactor this to some just_pressed?(:action) etc pattern per scene
      #       with defined input config per scene
      if keys.just_pressed?([Keys::Space, Keys::Enter])
        case items.focused
        when "new"
          @start_scene = :main
        when "continue"
          @continue = true
        when "exit"
          @exit = true
        end
      elsif keys.just_pressed?(Keys::Escape)
        @exit = true
      end
    end

    def draw(window : SF::RenderWindow)
      window.draw(title)
      items.draw(window)
    end
  end
end
