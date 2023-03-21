class TetrisGame
  def reset_lock_down_delay(reset_extensions=false)
    @current_tetromino[:lock_down_timeout] = LOCK_DOWN_DELAY
    @current_tetromino[:lock_down_extensions] = reset_extensions ? 0 : @current_tetromino[:lock_down_extensions] + 1
  end

  def lock_down
    @current_tetromino[:lock_down_timeout] -= 1

    if ((@current_tetromino[:lock_down_timeout] <= 0 || @current_tetromino[:hard_dropped]) && current_tetromino_colliding_y?) ||
       (@current_tetromino[:lock_down_extensions] >= 15 && (current_tetromino_colliding_x?(:left, :right) || current_tetromino_colliding_y?))
      # Make current tetromino part of the matrix
      current_tetromino_iterate do |mino, x, y|
        if mino
          @matrix[x][y] = @current_tetromino[:color]
        end
      end

      @current_tetromino = nil
      delay(SPAWN_DELAY) { spawn_tetromino }
    end
  end

  def locking_down?
    @current_tetromino[:lock_down] || false
  end
end
