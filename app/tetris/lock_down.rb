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
      # Make current tetromino part of the matrix
      @current_tetromino.each_with_coords do |mino, x, y|
        @matrix[x][y] = @current_tetromino.color if mino
      end

      @current_tetromino = nil
      delay SPAWN_DELAY do
        spawn_tetromino
        @hold_available = true
      end
    end
  end

  # Some actions reset the lock down delay. Unless, +reset_extensions+ is set,
  # this method will increment the number of times the delay has been extended
  # in this manner.
  #
  # @param reset_extensions [Boolean] whether or not to reset the delay extension counter
  def reset_lock_down_delay(reset_extensions=false)
    @current_tetromino.lock_down_timeout = LOCK_DOWN_DELAY
    @current_tetromino.lock_down_extensions =
      reset_extensions && @current_tetromino.extension_reset_allowed? ?
        0 : @current_tetromino.lock_down_extensions + 1
  end
end
