class TetrisGame
  def render_game
    render_background

    render_grid_lines

    render_matrix @matrix unless animating? :line_fall
    render_closed_shutters if @game_over

    if @current_tetromino
      render_ghost
      render_tetromino @current_tetromino unless animating? :hard_drop
    end

    render_queue
    render_held if @held_tetromino

    render_score

    animation_tick

    render_border
  end

  def render_border
    color = [150, 150, 150]

    # Horizontal lines
    (-9..MATRIX_WIDTH + 8).each do |x|
      render_mino x, -1, *color, border: false
      render_mino x, MATRIX_HEIGHT, *color, border: false, y_translate: PEEK_HEIGHT
    end

    # Vertical lines
    (-1..MATRIX_HEIGHT).each do |y|
      # Edges of matrix
      render_mino -1, y, *color, border: false
      render_mino MATRIX_WIDTH, y, *color, border: false

      # Far edges
      render_mino MATRIX_WIDTH + 8, y, *color, border: false
      render_mino -9, y, *color, border: false
    end

    # Separators beneath next up/held pieces
    [-8..-1, (MATRIX_WIDTH..MATRIX_WIDTH + 7)].each do |range|
      range.each { |x| render_mino x, 15, *color, border: false }
    end
  end

  def render_grid_lines
    r, g, b = GRID_COLOR

    @args.outputs.primitives << 9.times.map do |n|
      x = MATRIX_X0 + MINO_SIZE * (n + 1) - 1
      {
        primitive_marker: :solid,
        x: x,
        y: MATRIX_Y0,
        h: MATRIX_PX_HEIGHT,
        w: 2,
        r: r,
        g: g,
        b: b
      }
    end

    @args.outputs.primitives << 20.times.map do |n|
      y = MATRIX_Y0 + MINO_SIZE * (n + 1) - 1
      {
        primitive_marker: :solid,
        x: MATRIX_X0,
        y: y,
        h: 2,
        w: MATRIX_PX_WIDTH,
        r: r,
        g: g,
        b: b
      }
    end
  end

  # Render a single "mino" (one square of a tetromino).
  #
  # @param matrix_x [Integer] x-coordinate on the matrix
  # @param matrix_y [Integer] y-coordinate on the matrix
  # @param r [Integer] RGBa red component, 0-255
  # @param g [Integer] RGBa green component, 0-255
  # @param b [Integer] RGBa blue component, 0-255
  # @param a [Integer] RGBa alpha component, 0-255
  #
  # @param options [Hash] additional options
  # @option options [Integer] :size custom size in pixels
  # @option options [Integer] :x_translate custom x translation in pixels
  # @option options [Integer] :y_translate custom y translation in pixels
  # @option options [Boolean] :border whether or not to display a black border
  def render_mino(matrix_x, matrix_y, r, g, b, a=255, **options)
    [[:size, MINO_SIZE],
     [:x_translate, 0],
     [:y_translate, 0]].each { |option, default| options[option] ||= default }

    options[:border] ||= GRID_COLOR unless options[:border] == false

    x, y = mino_px_position matrix_x, matrix_y, size: options[:size]

    @args.outputs.primitives << {
      primitive_marker: :solid,
      x: x + options[:x_translate],
      y: y + options[:y_translate],
      w: options[:size],
      h: options[:size],
      r: r,
      g: g,
      b: b,
      a: a
    }

    if options[:border]
      r, g, b = options[:border]

      @args.outputs.primitives << {
        primitive_marker: :border,
        x: x + options[:x_translate],
        y: y + options[:y_translate],
        w: options[:size],
        h: options[:size],
        r: r,
        g: g,
        b: b
      }
    end
  end

  def mino_px_position(matrix_x, matrix_y, **options)
    options[:size] ||= MINO_SIZE

    [(1280 - (MATRIX_WIDTH * options[:size])) / 2 + (matrix_x * options[:size]),
     (720 - (MATRIX_HEIGHT * options[:size])) / 2 - (PEEK_HEIGHT / 2) + (matrix_y * options[:size])]
  end

  def render_matrix(matrix)
    matrix.each_with_index do |col, x|
      col.each_with_index do |color, y|
        render_mino x, y, *color if color && y < MATRIX_HEIGHT + 1
      end
    end
  end

  def render_tetromino(tetromino, **options)
    %i[x_translate y_translate].each { |opt| options[opt] ||= 0 }

    tetromino.each_with_coords do |mino, x, y|
      if mino && y < MATRIX_HEIGHT + 1
        render_mino x, y, *tetromino.color, x_translate: options[:x_translate],
                  border: options[:border], y_translate: options[:y_translate]
      end
    end
  end

  def render_ghost
    # Saving this as an instance variable so we can access it in an
    # animation later
    @ghost = @current_tetromino.clone

    # Add alpha channel
    @ghost.color << GHOST_ALPHA

    # Drop it until it hits something
    until @ghost.any? { |mino, x, y| mino && (y - 1 < 0 || @matrix[x][y - 1]) }
      @ghost.y -= 1
    end

    render_tetromino @ghost
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
      if mino
        render_mino x, y, *next_up.color,
                    x_translate: 12 + three_wide_push, y_translate: 9 + i_push
      end
    end

    @bag[1..5].each_with_index do |tetromino, i|
      # Similar adjustments to get the queue pieces nice and centered
      o_push = tetromino.shape == :o ? 1 : 0
      i_push = tetromino.shape == :i ? QUEUE_MINO_SIZE / -2 : 0
      three_wide_push = %i[l j t s z].include?(tetromino.shape) ? QUEUE_MINO_SIZE / 2 : 0

      tetromino.each_with_coords(13 + o_push, (11 + o_push) - (3 * i)) do |mino, x, y|
        if mino
          render_mino x, y, *tetromino.color, size: QUEUE_MINO_SIZE,
                      x_translate: 4 + three_wide_push, y_translate: 10 + i_push
        end
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

    @held_tetromino.each_with_coords(-6 + o_push, 16 + o_push) do |mino, x, y|
      if mino
        render_mino x, y, *@held_tetromino.color, @hold_available ? 255 : UNAVAILABLE_HOLD_ALPHA,
                    x_translate: -16 + three_wide_push, y_translate: 9 + i_push
      end
    end
  end

  def render_score
    @args.outputs.labels << time_elapsed.label(x: 355, y: 484, size: 4, alignment: :center)

    @args.outputs.labels << [
      "Score: #{@score}",
      "Lines: #{@lines}",
      "Level: #{@level}",
      "SPM: #{score_per_minute}",
      "LPM: #{lines_per_minute}",
      "BRN: #{@burnt_lines}",
      @tetris_lines > 0 ? "TRT: #{tetris_rate}" : nil
    ].span_vertically(x: 268, y: 440, spacing: 40, size: 2)

    if @back_to_back > 0
      @args.outputs.labels << "Streak: #{@back_to_back}".label(
        x: 355, y: @highest_streak > 0 ? 138 : 108,
        size: 4, alignment: :center
      )
    end

    if @highest_streak > 0
      @args.outputs.labels <<
        (@new_best_set ? "New Best!" : "Best Streak: #{@highest_streak}").
          label(x: 355, y: 98, alignment: :center)
    end
  end
end
