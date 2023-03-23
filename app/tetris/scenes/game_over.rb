class TetrisGame
  def game_over_init
    @input_timeout = 60

    # TODO: high score data
  end

  def game_over_tick
    @input_timeout -= 1
    if @input_timeout < 0 &&
       (@args.inputs.keyboard.key_down.space || @args.inputs.controller_one.a)
      set_scene :game
    end

    render_game_over
  end
end
