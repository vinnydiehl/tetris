class TetrisGame
  # Rendering main loop. This is called every frame and dispatches to
  # the various rendering subroutines defined here.
  def render
    render_background
    render_matrix

    if @current_tetromino
      render_ghost
      render_tetromino @current_tetromino
    end

    render_queue
    render_held if @held_tetromino

    # render_score
  end

  def render_background
    # Black background
    @args.outputs.solids << [0, 0, 1280, 720, 0, 0, 0]

    # Border

    color = [255, 255, 255]

    # Horizontal lines
    (-8..MATRIX_WIDTH + 7).each do |x|
      render_mino x, -1, *color
      render_mino x, MATRIX_HEIGHT, *color
    end

    # Vertical lines
    (-1..MATRIX_HEIGHT).each do |y|
      # Edges of matrix
      render_mino -1, y, *color
      render_mino MATRIX_WIDTH, y, *color

      # Far edges
      render_mino MATRIX_WIDTH + 8, y, *color
      render_mino -9, y, *color
    end

    # Separators beneath next up/held pieces
    [-8..-1, (MATRIX_WIDTH..MATRIX_WIDTH + 7)].each do |range|
      range.each { |x| render_mino x, 15, *color }
    end
  end

  # Render a single "mino" (one square of a tetromino).
  #
  # @param x [Integer] x-coordinate on the matrix
  # @param y [Integer] y-coordinate on the matrix
  # @param r [Integer] RGBa red component, 0-255
  # @param g [Integer] RGBa green component, 0-255
  # @param b [Integer] RGBa blue component, 0-255
  # @param a [Integer] RGBa alpha component, 0-255
  # @param size [Integer] custom size in pixels
  # @param x_translate [Integer] custom x translation in pixels
  # @param y_translate [Integer] custom y translation in pixels
  def render_mino(x, y, r, g, b, a=255, size=MINO_SIZE, x_translate=0, y_translate=0)
    matrix_x = (1280 - (MATRIX_WIDTH * size)) / 2
    matrix_y = (720 - (MATRIX_HEIGHT * size)) / 2

    @args.outputs.solids << [matrix_x + (x * size) + x_translate, matrix_y + (y * size) + y_translate, size, size, r, g, b, a]
  end

  def render_matrix
    @matrix.each_with_index do |col, x|
      col.each_with_index do |color, y|
        render_mino x, y, *color if color && y < MATRIX_HEIGHT
      end
    end
  end

  def render_tetromino(tetromino)
    tetromino.each_with_coords do |mino, x, y|
      render_mino x, y, *tetromino.color if mino && y < MATRIX_HEIGHT
    end
  end

  def render_ghost
    ghost = @current_tetromino.clone

    # Add alpha channel
    ghost.color << GHOST_ALPHA

    # Drop it until it hits something
    until ghost.any? { |mino, x, y| mino && (y - 1 < 0 || @matrix[x][y - 1]) }
      ghost.y -= 1
    end

    render_tetromino ghost
  end

  def render_queue
    next_up = @bag.first

    # Each piece will need either matrix grid or pixel adjustments to line them up nicely:

    # O pieces need a push 1 space to the right and 1 space up
    o_push = next_up.shape == :o ? 1 : 0
    # I pieces need to move 1/2 space down
    i_push = next_up.shape == :i ? MINO_SIZE / -2 : 0
    # The rest need to move 1/2 space right
    three_wide_push = %i[l j t s z].include?(next_up.shape) ? MINO_SIZE / 2 : 0

    next_up.each_with_coords(12 + o_push, 16 + o_push) do |mino, x, y|
      render_mino x, y, *next_up.color, 255, MINO_SIZE, 12 + three_wide_push, 2 + i_push if mino
    end

    @bag[1..5].each_with_index do |tetromino, i|
      # Similar adjustments to get the queue pieces nice and centered
      o_push = tetromino.shape == :o ? 1 : 0
      i_push = tetromino.shape == :i ? QUEUE_MINO_SIZE / -2 : 0
      three_wide_push = %i[l j t s z].include?(tetromino.shape) ? QUEUE_MINO_SIZE / 2 : 0

      tetromino.each_with_coords(13 + o_push, (11 + o_push) - (3 * i)) do |mino, x, y|
        render_mino x, y, *tetromino.color, 255, 28, 4 + three_wide_push, 10 + i_push if mino
      end
    end
  end

  def render_held
    # As with the queue rendering, adjustments to line things up:

    # O pieces need a push 1 space to the right and 1 space up
    o_push = @held_tetromino.shape == :o ? 1 : 0
    # I pieces need to move 1/2 space down
    i_push = @held_tetromino.shape == :i ? MINO_SIZE / -2 : 0
    # The rest need to move 1/2 space right
    three_wide_push = %i[l j t s z].include?(@held_tetromino.shape) ? MINO_SIZE / 2 : 0

    @held_tetromino.each_with_coords(- 6 + o_push, 16 + o_push) do |mino, x, y|
      if mino
        render_mino x, y, *@held_tetromino.color, @hold_available ? 255 : UNAVAILABLE_HOLD_ALPHA,
                    MINO_SIZE, -16 + three_wide_push, 2 + i_push
      end
    end
  end
end
