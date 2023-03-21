class TetrisGame
  def render_background
    # Black background
    @args.outputs.solids << [0, 0, 1280, 720, 0, 0, 0]

    # Border

    color = [255, 255, 255]

    # Horizontal lines
    (-1..MATRIX_WIDTH).each do |i|
      render_mino i, -1, *color
      render_mino i, MATRIX_HEIGHT, *color
    end

    # Vertical lines
    (-1..MATRIX_HEIGHT).each do |i|
      render_mino -1, i, *color
      render_mino MATRIX_WIDTH, i, *color
    end
  end

  # x and y are positions in the matrix, not pixels
  def render_mino(x, y, r, g, b, a=255)
    matrix_x = (1280 - (MATRIX_WIDTH * MINO_SIZE)) / 2
    matrix_y = (720 - (MATRIX_HEIGHT * MINO_SIZE)) / 2

    @args.outputs.solids << [matrix_x + (x * MINO_SIZE), matrix_y + (y * MINO_SIZE), MINO_SIZE, MINO_SIZE, r, g, b, a]
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

  def render
    render_background
    render_matrix

    if @current_tetromino
      render_ghost
      render_tetromino @current_tetromino
    end

    # render_score
  end
end
