require "./stage"

module Phase
  class Game < GSF::Game
    getter manager

    DebugVideoModes = false

    def initialize
      mode = SF::VideoMode.desktop_mode
      style = SF::Style::None

      {% if flag?(:linux) %}
        mode.width -= 50
        mode.height -= 100

        style = SF::Style::Default
      {% end %}

      super(title: "phase", mode: mode, style: style) #, default_height: 2100)

      window.framerate_limit = 69
      window.default_view.zoom(Screen.scaling_factor)

      if DebugVideoModes
        puts ">>> SF::VideoMode.fullscreen_modes:"
        puts ">>> #{SF::VideoMode.fullscreen_modes}"
        puts ">>> SF::VideoMode.desktop_mode:"
        puts ">>> #{SF::VideoMode.desktop_mode}"
        puts ">>> Screen.scaling_factor: #{Screen.scaling_factor}"
      end

      @stage = Stage.new(window)
    end
  end
end
