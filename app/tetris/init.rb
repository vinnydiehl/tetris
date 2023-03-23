class TetrisGame
  def initialize(args)
    @args = args
    @scene = :main_menu

    @delayed_procs = []
  end

  def tick
    send "#{@scene}_tick"
  end
end
