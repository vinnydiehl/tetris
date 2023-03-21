class TetrisGame
  def current_tetromino
    @current_tetromino ? @current_tetromino[:minos] : nil
  end

  def current_tetromino_iterate(&block)
    current_tetromino.each_with_index do |col, x|
      col.each_with_index do |mino, y|
        block.call mino, @current_tetromino[:x] + x, @current_tetromino[:y] + y
      end
    end
  end

  def current_tetromino_any?(&block)
    current_tetromino.each_with_index.any? do |col, x|
      col.each_with_index.any? do |mino, y|
        block.call mino, @current_tetromino[:x] + x, @current_tetromino[:y] + y
      end
    end
  end

  # The random generator is fairly simple: shuffle the pieces and put them in a "bag",
  # draw them in order, then reshuffle when the bag is empty. We keep the bag size > 7
  # so that the queue (next 7 pieces, visible) is always filled up
  def spawn_tetromino
    @bag.concat PIECES.shuffle if @bag.size < 8

    @current_tetromino = @bag.shift

    @current_tetromino.merge!({
      y: 21 - current_tetromino.first.size,
      x: 5 - (current_tetromino.size / 2).ceil,
      rotation: 0,
      age: 0,
      lock_down_timeout: LOCK_DOWN_DELAY,
      lock_down_extensions: 0
    })

    reset_gravity_delay GRAVITY_VALUES[@level]
  end

  def current_tetromino_colliding_x?(*directions)
    unless directions.all? { |dir| %i[left right].include?(dir) }
      raise ArgumentError, "expected :left or :right"
    end

    directions.all? do |dir|
      current_tetromino_any? do |mino, x, y|
        mino &&
          ((dir == :left &&
              (x <= 0 || @matrix[x - 1][y])) ||
           (dir == :right &&
              (x >= MATRIX_WIDTH - 1 || @matrix[x + 1][y])))
      end
    end
  end

  def current_tetromino_colliding_y?
    current_tetromino_any? do |mino, x, y|
      mino && (y <= 0 || @matrix[x][y - 1])
    end
  end
end
