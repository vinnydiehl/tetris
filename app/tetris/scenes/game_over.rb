class TetrisGame
  def game_over_init
    # read high score data
  end

  def game_over_tick
    if @args.inputs.keyboard.key_down.space || @args.inputs.controller_one.a
      set_scene :game
    end

    render_game_over
  end
end
