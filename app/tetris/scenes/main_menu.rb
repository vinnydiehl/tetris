class TetrisGame
  def main_menu_init
    set_music "main_menu"

    @starting_level ||= 1

    @selector_timeout = 0
    @selector_clicks_held = 0
  end

  def main_menu_tick
    if inputs_any? kb: :escape, c1: :start
      play_sound_effect "menus/button"
      set_scene :controls
    elsif inputs_any? kb: :space, c1: :a
      play_sound_effect "menus/action"
      set_scene :game
    end

    if @args.inputs.up_down != 0
      if @selector_timeout < 0
        # Hey, it sounds good here
        play_sound_effect "tetromino/move"

        @starting_level = [@starting_level + @args.inputs.up_down, 1, 15].sort[1]

        # Mechanism to make the selector click slowly for the first 3 clicks,
        # then quickly the rest of the way if up/down is held
        @selector_timeout = @selector_clicks_held < 3 ? 0.5.seconds : 0.1.seconds
        @selector_clicks_held += 1
      end
    else
      @selector_timeout = 0
      @selector_clicks_held = 0
    end

    @selector_timeout -= 1
  end
end
