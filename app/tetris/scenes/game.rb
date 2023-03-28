class TetrisGame
  def game_init
    set_music "game_intro", "game_loop"

    init_animations
    begin_animation :countdown

    # At the start of the game there is a "Ready, Go" animation; during this time
    # they can move the piece left and right, but that's it; it will not fall, and
    # the timer is not running.
    @game_started = false
    # Used to freeze the screen briefly after game over animation
    @game_over = false

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
    @t_spins_scored = 0
    @mini_t_spins_scored = 0

    @gravity = GRAVITY_VALUES[1]

    @matrix = empty_matrix

    @das_timeout = DAS
    @as_frame_timer = 0

    @bag = []
    @held_tetromino = nil

    spawn_tetromino
  end

  def game_tick
    if @game_started && !animating?(:game_over)
      @timer += 1
    end

    handle_delayed_procs
    handle_input

    if @current_tetromino && @game_started
      apply_gravity unless current_tetromino_colliding_y?

      # Setting this starts the lock down, which can no longer
      # be stopped even if you shift off the stack
      @current_tetromino.lock_down = true if current_tetromino_colliding_y? && !locking_down?

      lock_down if locking_down?
    end

    check_line_clear
    handle_scoring

    if !@current_tetromino && !@spawning && !@game_over &&
       %i[line_clear line_fall game_over].none? { |a| animating? a }
      delay(SPAWN_DELAY) { spawn_tetromino }
      @spawning = true
    end
  end

  def handle_input
    if inputs_any? kb: %i[escape], c1: :start
      set_scene :pause, false
      return
    end

    if @args.inputs.left != @args.inputs.right
      direction = @args.inputs.left ? :left : :right

      if @current_tetromino && !current_tetromino_colliding_x?(direction) &&
         (@das_timeout == DAS || (@das_timeout < 0 && @as_frame_timer == 0))
        play_sound_effect "tetromino/move"

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
      if inputs_any?(kb: %i[shift c], c1: %i[x y]) && @game_started
        if @hold_available
          play_sound_effect "tetromino/hold#{@held_tetromino ? '' : '_initial'}"
          hold_current_tetromino
        else
          play_sound_effect "tetromino/hold_fail"
        end
      else
        if inputs_any?(kb: :space, c1: %i[directional_up a]) && @game_started
          @current_tetromino.hard_dropped = true
        end

        @current_tetromino.soft_dropping = @args.inputs.down ? true : false

        calculate_gravity(@args.inputs.down)

        if inputs_any? kb: %i[up x], c1: :r1
          play_sound_effect "tetromino/rotate"
          rotate_current_tetromino(:cw)
        end

        if inputs_any? kb: %i[control z], c1: :l1
          play_sound_effect "tetromino/rotate"
          rotate_current_tetromino(:ccw)
        end
      end
    end
  end

  # @return [Array<Array>] a 10x20 2D array full of nils
  def empty_matrix
    Array.new(MATRIX_WIDTH) { Array.new(MATRIX_HEIGHT, nil) }
  end
end
