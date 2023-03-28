class TetrisGame
  def render_game
    render_background

    render_matrix @matrix unless animating? :line_fall
    render_closed_shutters if @game_over

    if @current_tetromino
      render_ghost
      render_tetromino @current_tetromino
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
    (-8..MATRIX_WIDTH + 7).each do |x|
      render_mino x, -1, *color, border: false
      render_mino x, MATRIX_HEIGHT, *color, border: false
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

  # Render a single "mino" (one square of a tetromino).
  #
  # @param x [Integer] x-coordinate on the matrix
  # @param y [Integer] y-coordinate on the matrix
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
  def render_mino(x, y, r, g, b, a=255, **options)
    [[:size, MINO_SIZE],
     [:x_translate, 0],
     [:y_translate, 0]].each { |option, default| options[option] ||= default }

    matrix_x = (1280 - (MATRIX_WIDTH * options[:size])) / 2
    matrix_y = (720 - (MATRIX_HEIGHT * options[:size])) / 2

    @args.outputs.primitives << {
      primitive_marker: :solid,
      x: matrix_x + (x * options[:size]) + options[:x_translate],
      y: matrix_y + (y * options[:size]) + options[:y_translate],
      w: options[:size],
      h: options[:size],
      r: r,
      g: g,
      b: b,
      a: a
    }

    # We can't set this with `||= true` up top, obviously. Not that I tried...
    unless options[:border] == false
      @args.outputs.primitives << {
        primitive_marker: :border,
        x: matrix_x + (x * options[:size]) + options[:x_translate],
        y: matrix_y + (y * options[:size]) + options[:y_translate],
        w: options[:size],
        h: options[:size],
        r: 0,
        g: 0,
        b: 0
      }
    end
  end

  def render_matrix(matrix)
    matrix.each_with_index do |col, x|
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
      if mino
        render_mino x, y, *next_up.color,
                    x_translate: 12 + three_wide_push, y_translate: 2 + i_push
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

    @held_tetromino.each_with_coords(- 6 + o_push, 16 + o_push) do |mino, x, y|
      if mino
        render_mino x, y, *@held_tetromino.color, @hold_available ? 255 : UNAVAILABLE_HOLD_ALPHA,
                    x_translate: -16 + three_wide_push, y_translate: 2 + i_push
      end
    end
  end

  def render_score
    @args.outputs.labels << [
      {
        text: time_elapsed,
        x: 355,
        y: 490,
        size_enum: 4,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "Score: #{@score}",
        x: 268,
        y: 440,
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "Lines: #{@lines}",
        x: 268,
        y: 400,
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "Level: #{@level}",
        x: 268,
        y: 360,
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "SPM: #{score_per_minute}",
        x: 268,
        y: 320,
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "LPM: #{lines_per_minute}",
        x: 268,
        y: 280,
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "BRN: #{@burnt_lines}",
        x: 268,
        y: 240,
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255
      }
    ]

    if @tetris_lines > 0
      @args.outputs.labels << {
        text: "TRT: #{tetris_rate}",
        x: 268,
        y: 200,
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255
      }
    end

    if @back_to_back > 0
      @args.outputs.labels << {
        text: "Streak: #{@back_to_back}",
        x: 355,
        y: @highest_streak > 0 ? 145 : 115,
        size_enum: 4,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      }
    end

    if @highest_streak > 0
      @args.outputs.labels << {
        text: @new_best_set ? "New Best!" : "Best Streak: #{@highest_streak}",
        x: 355,
        y: 105,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      }
    end
  end
end
