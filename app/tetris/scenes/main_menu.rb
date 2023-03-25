class TetrisGame
  def main_menu_init
    set_music "main_menu"
  end

  def main_menu_tick
    if inputs_any? kb: :escape, c1: :start
      play_sound_effect "menus/button"
      set_scene :controls
    elsif inputs_any? kb: :space, c1: :a
      play_sound_effect "menus/action"
      set_scene :game
    end
  end
end
