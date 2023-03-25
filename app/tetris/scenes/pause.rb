class TetrisGame
  def pause_init
    set_volume 20
  end

  def pause_tick
    if inputs_any? kb: :c, c1: :y
      set_scene :controls
    elsif inputs_back?
      # Continue
      set_volume 100
      set_scene_back
    elsif inputs_any? kb: :enter, c1: :select
      # Restart
      set_scene :game
    end
  end
end
