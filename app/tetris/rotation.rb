KICK_TESTS = [
  [[0, 0], [-1, 0], [-1, 1], [0, -2], [-1, -2]],
  [[0, 0], [1, 0], [1, -1], [0, 2], [1, 2]],
  [[0, 0], [1, 0], [1, 1], [0, -2], [1, -2]],
  [[0, 0], [-1, 0], [-1, -1], [0, 2], [-1, 2]]
]

KICK_TESTS_I = [
  [[0, 0], [-2, 0], [1, 0], [-2, -1], [1, 2]],
  [[0, 0], [-1, 0], [2, 0], [-1, 2], [2, -1]],
  [[0, 0], [2, 0], [-1, 0], [2, 1], [-1, -2]],
  [[0, 0], [1, 0], [-2, 0], [1, -2], [-2, 1]]
]

class TetrisGame
  def rotate_current_tetromino(direction)
    raise ArgumentError, "expected :cw or :ccw" unless %i[cw ccw].include?(direction)

    # SRS Wall kicks try 5 different translations, if any succeed, it places
    # the tetromino. We'll create a simulated tetromino to try them out
    sim_tetromino = @current_tetromino.clone

    # All of the shapes are represented as square 2D arrays (2x2, 3x3, or 4x4)
    # which are rotated directly around their centers.
    sim_tetromino.minos = direction == :cw ?
      sim_tetromino.minos.transpose.map(&:reverse) :
      sim_tetromino.minos.map(&:reverse).transpose

    kick_tests = sim_tetromino.shape == :i ? KICK_TESTS_I : KICK_TESTS

    # The test cases are indexed based on the rotation position
    i = direction == :cw ? sim_tetromino.rotation : (sim_tetromino.rotation - 1) % 4
    sign = direction == :cw ? 1 : -1

    last_test_tried = 0

    success = kick_tests[i].each_with_index.any? do |translation, kick_test_i|
      last_test_tried = kick_test_i

      # Translate it (from the point where it originated, the x and y of @current_tetromino)
      sim_tetromino.x = @current_tetromino.x + (translation.x * sign)
      sim_tetromino.y = @current_tetromino.y + (translation.y * sign)

      # Success if none of the simulated tetromino's minos are
      # overlapping the matrix, or out-of-bounds
      sim_tetromino.none? do |mino, x, y|
        mino && (x < 0 || x >= MATRIX_WIDTH || y < 0 || @matrix[x][y])
      end
    end

    if success
      # If the piece has gained height, disable the extension reset so
      # player can't keep climbing infinitely
      if sim_tetromino.lowest_y > @current_tetromino.lowest_y
        sim_tetromino.disable_extension_reset
      end

      @current_tetromino = sim_tetromino

      # Cycle between 0..3
      @current_tetromino.rotation = (@current_tetromino.rotation + sign) % 4
      @current_tetromino.last_movement = last_test_tried

      reset_lock_down_delay
    end
  end
end
