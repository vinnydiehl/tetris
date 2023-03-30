class TetrisGame
  def main_menu_init
    set_music "main_menu"

    @starting_level ||= 1

    @selector_timeout = 0
    @selector_clicks_held = 0
    @selector_last_clicked = @args.state.tick_count
    @selector_last_direction = 0

    main_menu_ui_init
  end

  def main_menu_tick
    if inputs_any? kb: :escape, c1: :start
      play_sound_effect "menus/button"
      set_scene :controls
    elsif inputs_any? kb: :space, c1: :a
      play_sound_effect "menus/action"
      set_scene :game
    end

    @selector_buttons.each do |button|
      # We're going to be pulsing the arrows white on some actions, this makes it fade back.
      # Doing this before setting bright alpha so there is no flickering
      button[:a] -= 1 if button[:a] > ARROW_ALPHA

      # Pulse button white on hover
      button[:a] = ARROW_BRIGHT_ALPHA if @args.inputs.mouse.intersect_rect?(button)
    end

    # Pulse button white when using up/down inputs
    if (@args.inputs.down && @starting_level > 0) || (@args.inputs.up && @starting_level < 15)
      @selector_buttons.find { |b| b[:value] == @args.inputs.up_down }[:a] = ARROW_BRIGHT_ALPHA
    end

    button_clicked = @selector_buttons.find do |button|
      @args.inputs.mouse.click&.point&.intersect_rect? button
    end

    if @args.inputs.up_down != 0 || button_clicked
      if @selector_timeout < 0
        # Hey, it sounds good here
        play_sound_effect "tetromino/move"

        @selector_last_direction =
          button_clicked ? button_clicked[:value] : @args.inputs.up_down

        original = @starting_level
        @starting_level = [@starting_level + @selector_last_direction, 1, 15].sort[1]

        if @starting_level != original
          # Mechanism to make the selector click slowly for the first 3 clicks,
          # then quickly the rest of the way if up/down is held
          @selector_timeout = @selector_clicks_held < 3 ? 0.5.seconds : 0.1.seconds
          @selector_clicks_held += 1

          # The alpha pulses in and out based on the tick count. This resets the
          # counter so that when you change the level, it always starts at full alpha
          @selector_last_clicked = @args.state.tick_count
        end
      end
    else
      @selector_timeout = 0
      @selector_clicks_held = 0
    end

    @selector_timeout -= 1
  end
end
