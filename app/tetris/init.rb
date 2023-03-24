class TetrisGame
  def initialize(args)
    @args = args
    set_scene :main_menu
  end

  def tick
    # Save this so that even if the scene changes during the tick, it is
    # still rendered before switching scenes.
    scene = @scene

    send "#{scene}_tick"
    send "render_#{scene}"
  end

  def set_scene(scene)
    # See delay.rb for an explanation of this
    @delayed_procs = []

    @scene = scene

    init_method = :"#{@scene}_init"
    send init_method if self.class.method_defined?(init_method)
  end
end
