class TetrisGame
  def main_menu_tick
    if @args.inputs.keyboard.key_down.space
      start_game
      @scene = :game
    end

    render_main_menu
  end
end
