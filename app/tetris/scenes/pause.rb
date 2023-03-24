class TetrisGame
  def pause_tick
    if @args.inputs.keyboard.key_down.space || @args.keyboard.key_down.escape ||
       @args.inputs.controller_one.a || @args.inputs.controller_one.key_down.start
      # Continue
      @scene = :game
    elsif @args.inputs.keyboard.key_down.enter || @args.inputs.controller_one.select
      # Restart
      set_scene :game
    end
  end
end
