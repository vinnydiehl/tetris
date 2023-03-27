class TetrisGame
  def pause_init
    play_sound_effect "menus/pause"
    set_volume 20
  end

  def pause_tick
    if inputs_any? kb: :c, c1: :y
      play_sound_effect "menus/button"
      set_scene :controls
    elsif inputs_back?
      # Continue
      play_sound_effect "menus/unpause"
      set_volume 100
      set_scene_back
    elsif inputs_any? kb: :enter, c1: :select
      # Restart
      play_sound_effect "menus/action"
      set_volume 100
      set_scene :game
    end
  end
end
