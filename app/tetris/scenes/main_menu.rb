class TetrisGame
  def main_menu_tick
    if @args.inputs.keyboard.key_down.space || @args.inputs.controller_one.a
      set_scene :game
    end

    render_main_menu
  end
end
