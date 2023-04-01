# frozen_string_literal: true

class TetrisGame
  def controls_tick
    if inputs_back?
      play_sound_effect "menus/button"
      set_scene_back
    end
  end
end
