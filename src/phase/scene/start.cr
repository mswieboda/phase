module Phase::Scene
  class Start < GSF::Scene
    getter title : SF::Text
    getter start_scene : Symbol?
    getter items

    TitleTextColor = SF::Color::Green

    def initialize
      super(:start)

      @start_scene = nil
      @items = GSF::MenuItems.new(
        font: Font.default,
        labels: ["start", "exit"],
        size: 36
      )

      @title = SF::Text.new("phase", Font.default, 60)
      @title.fill_color = TitleTextColor

      title_x = Screen.width / 2 - @title.global_bounds.width / 2
      title_y = Screen.height / 4 - @title.global_bounds.height / 2

      @title.position = {title_x, title_y}
    end

    def reset
      super

      @start_scene = nil
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      items.update(frame_time, keys, mouse)

      # TODO: refactor this to some just_pressed?(:action) etc pattern per scene
      #       with defined input config per scene
      if keys.just_pressed?([Keys::Space, Keys::Enter]) ||
         joysticks.just_pressed?([Joysticks::A, Joysticks::B, Joysticks::X, Joysticks::Y])
        case items.focused
        when "start"
          @start_scene = :main
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
