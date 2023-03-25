class TetrisGame
  def main_menu_init
    set_music "main_menu"
  end

  def main_menu_tick
    if inputs_any? kb: :escape, c1: :start
      set_scene :controls
    elsif inputs_any? kb: :space, c1: :a
      set_scene :game
    end
  end
end
