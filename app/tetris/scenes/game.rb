class TetrisGame
  def game_init
    # This gets played at the end of the countdown animation
    @args.audio[:music] = nil

    init_animations
    begin_animation :countdown

    # At the start of the game there is a "Ready, Go" animation; during this time
    # they can move the piece left and right, but that's it; it will not fall, and
    # the timer is not running.
    @game_started = false
    # Used to freeze the screen briefly after game over animation
    @game_over = false

    @timer = 0
    @score = 0
    @lines = 0
    @level = @starting_level

    # This is set dynamically based on @starting_level,
    # needs to start at 0 for that algorithm
    @lines_needed = 0
    set_lines_needed

    # @lines does not refer to the actual amount of lines cleared; they may be
    # awarded as bonuses. This is the actual amount cleared, for statistics purposes
    @actual_lines_cleared = 0
    @burnt_lines = 0

    @clears =\
      %i[single double triple tetris all_clear
         t_spin t_spin_single t_spin_double t_spin_triple
         mini_t_spin mini_t_spin_single mini_t_spin_double].map do |type|
        { type => 0 }
      end.inject(&:merge)

    init_metrics

    @back_to_back = 0
    @highest_streak = 0
    @new_best_set = false

    # This will indicate whether a T-Spin (and what type,
    # :full or :mini) was scored this turn
    @t_spin = nil
    @t_spins_scored = 0
    @mini_t_spins_scored = 0
    @t_spin_lines_cleared = 0

    @gravity = GRAVITY_VALUES[1]

    @matrix = empty_matrix

    @das_timeout = DAS
    @as_frame_timer = 0

    @bag = []
    @held_tetromino = nil

    spawn_tetromino
  end

  def game_tick
    if @game_started && !@game_over
      @timer += 1
    end

    handle_delayed_procs

    unless animating?(:hard_drop) || @game_over
      handle_input unless @current_tetromino&.hard_dropped

      if @current_tetromino && @game_started && !@game_over
        apply_gravity unless current_tetromino_colliding_y?

        # Setting this starts the lock down, which can no longer
        # be stopped even if you shift off the stack
        @current_tetromino.lock_down = true if current_tetromino_colliding_y? && !locking_down?

        lock_down if locking_down?
      end
    end

    check_line_clear
    handle_scoring
    calculate_metrics if @metrics_totals[:drops] > 0

    if !@current_tetromino && !@spawning &&
       %i[line_clear line_fall].none? { |a| animating? a }
      delay(SPAWN_DELAY) { spawn_tetromino unless @game_over }
      @spawning = true
    end
  end

  def handle_input
    if inputs_any? kb: %i[escape], c1: :start
      if !$gtk.production? && @timer > 0 && (l_r_held? || @kb_inputs_held.alt)
        # Freeze mode (development only)
        @game_started = !@game_started
      else
        # Pause
        set_scene :pause, false
        return
      end
    end

    if @args.inputs.left != @args.inputs.right
      direction = @args.inputs.left ? :left : :right

      # The @current_tetromino check is internal to allow the DAS input to
      # buffer while there isn't a piece in play, e.g. if you hold right
      # during the line clear animation, the next piece will immediately
      # auto-shift to the right upon spawning.
      if @current_tetromino && !current_tetromino_colliding_x?(direction) &&
         (@das_timeout == DAS || (@das_timeout < 0 && @as_frame_timer == 0))
        play_sound_effect "tetromino/move"

        @current_tetromino.x += direction == :left ? -1 : 1

        @current_tetromino.last_movement = :side

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

      @metrics[:presses] += 1 unless @holding_dir || !@current_tetromino
      @holding_dir = true
    else
      @last_direction = nil
      @das_timeout = DAS
      @as_frame_timer = 0
      @holding_dir = false
    end

    if @current_tetromino
      if inputs_any?(kb: %i[shift c], c1: %i[x y]) && @game_started
        if @hold_available
          play_sound_effect "tetromino/hold#{@held_tetromino ? '' : '_initial'}"
          hold_current_tetromino
        else
          play_sound_effect "tetromino/hold_fail"

          # Failed hold counts as a button press, sorry ;)
          @metrics[:presses] += 1
        end
      else
        if inputs_any?(kb: :space, c1: %i[directional_up a]) && @game_started
          begin_animation :hard_drop unless current_tetromino_colliding_y?
          @current_tetromino.hard_dropped = true
          @current_tetromino.last_movement = :gravity
          @metrics[:presses] += 1
        end

        if @args.inputs.down
          @current_tetromino.soft_dropping = true
          @metrics[:presses] += 1 unless @holding_down
          @holding_down = true
        else
          @current_tetromino.soft_dropping = false
          @holding_down = false
        end

        calculate_gravity

        if inputs_any? kb: %i[up x], c1: %i[r1 r2]
          play_sound_effect "tetromino/rotate"
          rotate_current_tetromino(:cw)
          @metrics[:presses] += 1
        end

        if inputs_any? kb: %i[control z], c1: %i[l1 l2]
          play_sound_effect "tetromino/rotate"
          rotate_current_tetromino(:ccw)
          @metrics[:presses] += 1
        end
      end
    end
  end

  # @return [Array<Array>] a 10x20 2D array full of nils
  def empty_matrix
    Array.new(MATRIX_WIDTH) { Array.new(MATRIX_HEIGHT, nil) }
  end
end
