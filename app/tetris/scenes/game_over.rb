class TetrisGame
  def game_over_init
    @input_timeout = 60

    # TODO: high score data
  end

  def game_over_tick
    @input_timeout -= 1
    if @input_timeout < 0 && inputs_any?(kb: :space, c1: :a)
      set_scene :game
    end
  end
end
