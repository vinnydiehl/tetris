class TetrisGame
  def game_tick
    @timer += 1

    handle_delayed_procs
    handle_input

    if @current_tetromino
      apply_gravity unless current_tetromino_colliding_y?

      # Setting this starts the lock down, which can no longer
      # be stopped even if you shift off the stack
      @current_tetromino.lock_down = true if current_tetromino_colliding_y? && !locking_down?

      lock_down if locking_down?
    end

    clear_lines
    handle_scoring

    render_game
  end

  def start_game
    @timer = 0
    @level = 1
    @score = 0
    @lines = 0

    # @lines does not refer to the actual amount of lines cleared; they may be
    # awarded as bonuses. This is the actual amount cleared, for statistics purposes
    @actual_lines_cleared = 0
    @tetris_lines = 0
    @burnt_lines = 0

    @back_to_back = 0
    @highest_streak = 0
    @new_best_set = false

    # This will indicate whether a T-Spin (and what type,
    # :full or :mini) was scored this turn
    @t_spin = nil

    @gravity = GRAVITY_VALUES[1]

    @matrix = Array.new(MATRIX_WIDTH) { Array.new(MATRIX_HEIGHT, nil) }

    @das_timeout = DAS
    @as_frame_timer = 0

    @bag = []
    @held_tetromino = nil
    @hold_available = true

    spawn_tetromino
  end

  def handle_input
    if @args.inputs.left != @args.inputs.right
      direction = @args.inputs.left ? :left : :right

      if @current_tetromino && !current_tetromino_colliding_x?(direction) &&
         (@das_timeout == DAS || (@das_timeout < 0 && @as_frame_timer == 0))
        @current_tetromino.x += direction == :left ? -1 : 1

        if locking_down?
          reset_lock_down_delay
          reset_gravity_delay
        end
      end

      # Check if direction has changed
      if @last_direction != direction
        @das_timeout = DAS
        @as_frame_timer = 0
      end

      @last_direction = direction
      @das_timeout -= 1

      if @das_timeout < 0
        @as_frame_timer = (@as_frame_timer - 1) % 3
      end
    else
      @last_direction = nil
      @das_timeout = DAS
      @as_frame_timer = 0
    end

    if @current_tetromino
      kb_inputs = @args.inputs.keyboard.key_down
      gp_inputs = @args.inputs.controller_one.key_down

      if @hold_available && (kb_inputs.space || gp_inputs.x || gp_inputs.y)
        hold_current_tetromino
      else
        if kb_inputs.w || kb_inputs.up ||
           gp_inputs.directional_up || gp_inputs.a
          @current_tetromino.hard_dropped = true
        end

        @current_tetromino.soft_dropping = @args.inputs.down ? true : false

        calculate_gravity(@args.inputs.down)

        if kb_inputs.e || gp_inputs.r1
          rotate_current_tetromino(:cw)
        end

        if kb_inputs.q || gp_inputs.l1
          rotate_current_tetromino(:ccw)
        end
      end
    end
  end
end
