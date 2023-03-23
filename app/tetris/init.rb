class TetrisGame
  def initialize(args)
    @args = args
    set_scene :main_menu
  end

  def tick
    send "#{@scene}_tick"
  end

  def set_scene(scene)
    # See delay.rb for an explanation of this
    @delayed_procs = []

    @scene = scene

    init_method = :"#{@scene}_init"
    send init_method if self.class.method_defined?(init_method)
  end
end
