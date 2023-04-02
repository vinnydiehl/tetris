# frozen_string_literal: true

class TetrisGame
  def game_over_init
    set_music "game_over"

    # Timeout to prevent skipping this screen if player is mashing the
    # A button as they game over
    @input_timeout = 60

    # TODO: high score data
  end

  def game_over_tick
    @input_timeout -= 1
    if @input_timeout < 0 && inputs_any?(kb: :space, c1: :a)
      play_sound_effect "menus/action"
      set_scene :game
    elsif l_r_held? || @kb_inputs.backspace
      # Main menu
      play_sound_effect "menus/action"
      set_scene :main_menu
    end
  end
end
