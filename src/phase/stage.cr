require "./scene/start"
require "./scene/main"

module Phase
  class Stage < GSF::Stage
    getter start
    getter main

    def initialize(window : SF::RenderWindow)
      super(window)

      @start = Scene::Start.new
      @main = Scene::Main.new(window)

      @scene = start
    end

    def check_scenes
      case scene.name
      when :start
        if scene.exit?
          @exit = true
        elsif start_scene = start.start_scene
          start(:main) if start_scene == :main
        elsif start.continue?
          switch(main)
        end
      when :main
        switch(start) if scene.exit?
        start(:main) if main.restart?
      end
    end

    def start(scene_name : Symbol)
      if scene_name == :main
        @main = Scene::Main.new(window)
        switch(@main)
      end
    end
  end
end
