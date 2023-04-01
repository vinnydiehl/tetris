# frozen_string_literal: true

class TetrisGame
  def initialize(args)
    @args = args

    # Gain value, 0 to 1
    @volume = 1
    @music_enabled = true

    @scene_stack = []
    set_scene :main_menu
  end

  def tick
    @kb_inputs = @args.inputs.keyboard.key_down
    @c1_inputs = @args.inputs.controller_one.key_down

    music_tick

    # Save this so that even if the scene changes during the tick, it is
    # still rendered before switching scenes.
    scene = @scene
    send "#{scene}_tick"
    send "render_#{scene}"
  end

  def set_scene(scene, reset_delayed_procs=true)
    # See delay.rb for an explanation of this
    @delayed_procs = [] if reset_delayed_procs

    @scene = scene
    @scene_stack << scene

    init_method = :"#{@scene}_init"
    send init_method if self.class.method_defined?(init_method)
  end

  def set_scene_back
    @scene_stack.pop
    @scene = @scene_stack.last
  end
end
