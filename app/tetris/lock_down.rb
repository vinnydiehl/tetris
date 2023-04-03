class TetrisGame
  # @return [Boolean] whether or not lock down has initiated on the current tetromino
  def locking_down?
    @current_tetromino.lock_down || false
  end

  # Runs every frame that lock down has initiated for the current tetromino.
  def lock_down
    @current_tetromino.lock_down_timeout -= 1

    if ((@current_tetromino.lock_down_timeout <= 0 || @current_tetromino.hard_dropped) && current_tetromino_colliding_y?) ||
       (@current_tetromino.lock_down_extensions >= MAX_LOCK_DOWN_ADJUSTMENTS && (current_tetromino_colliding_x?(:left, :right) || current_tetromino_colliding_y?))
      # Game over if you lock out above the grid
      if @current_tetromino.all? { |mino, _, y| mino ? y >= MATRIX_HEIGHT  : true }
        begin_animation :game_over
      end

      unless @game_over || @current_tetromino.hard_dropped
        play_sound_effect "tetromino/lock"
      end

      check_t_spin

      # Make current tetromino part of the matrix
      @current_tetromino.each_with_coords do |mino, x, y|
        @matrix[x][y] = @current_tetromino.color if mino
      end

      # For tracking metrics averages. Every time a tetromino is dropped, the
      # metrics for that frame are added to a total, and the drops are counted.
      @metrics_totals[:drops] += 1
      %i[accomodation slope bumpiness max_height min_height presses].each do |metric|
        @metrics_totals[metric] += @metrics[metric]
      end

      @current_tetromino = nil
    end
  end

  # Some actions reset the lock down delay. Unless, +reset_extensions+ is set,
  # this method will increment the number of times the delay has been extended
  # in this manner.
  #
  # @param reset_extensions [Boolean] whether or not to reset the delay extension counter
  def reset_lock_down_delay(reset_extensions=false)
    @current_tetromino.lock_down_timeout = LOCK_DOWN_DELAY

    if reset_extensions
      # Moving downward also resets the extensions, but this is disallowed if the
      # tetromino has rotated such that it has moved upwards in the grid.
      @current_tetromino.lock_down_extensions = 0 if @current_tetromino.extension_reset_allowed?
    else
      @current_tetromino.lock_down_extensions += 1
    end
  end

  def check_t_spin
    return unless @current_tetromino.shape == :t && @current_tetromino.last_movement.is_a?(Integer)

    # Points a, b, c, and d are oriented thusly around the T tetromino:
    #
    #    a   1   b
    #    1   1   1
    #    c   nil d
    #
    # They rotate with the tetromino. This table uses the rotation index to
    # get the offset from [@current_tetromino.x][@current_tetromino.y] to
    # one of those points:
    a = [[0, 2], [2, 2], [2, 0], [0, 0]][@current_tetromino.rotation]
    b = [[2, 2], [2, 0], [0, 0], [0, 2]][@current_tetromino.rotation]
    c = [[0, 0], [0, 2], [2, 2], [2, 0]][@current_tetromino.rotation]
    d = [[2, 0], [0, 0], [0, 2], [2, 2]][@current_tetromino.rotation]

    # Check if the flat side is against a wall; if so, c and d are filled
    against_wall =
      (@current_tetromino.rotation == 0 && @current_tetromino.y == -1) ||
      (@current_tetromino.rotation == 1 && @current_tetromino.x == -1) ||
      (@current_tetromino.rotation == 3 && @current_tetromino.x + c.x >= MATRIX_WIDTH)

    # Check these spots against the matrix and the walls (a and b can't be wall-adjacent)
    a_filled = @matrix[@current_tetromino.x + a.x][@current_tetromino.y + a.y]
    b_filled = @matrix[@current_tetromino.x + b.x][@current_tetromino.y + b.y]
    c_filled = against_wall || @matrix[@current_tetromino.x + c.x][@current_tetromino.y + c.y]
    d_filled = against_wall || @matrix[@current_tetromino.x + d.x][@current_tetromino.y + d.y]

    # Conditions are as follows (Mini T-Spin is more lenient)
    t_spin_condition = (a_filled && b_filled) && (c_filled || d_filled)
    mini_t_spin_condition = (a_filled || b_filled) && (c_filled && d_filled)

    # If the mini conditions are met with a kick test of 5, however, it counts as a full
    if (t_spin_condition || (mini_t_spin_condition && @current_tetromino.last_movement == 5))
      @t_spin = :full
    elsif mini_t_spin_condition
      @t_spin = :mini
    end
  end
end
