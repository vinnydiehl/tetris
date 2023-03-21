# The tetronimos' minos are represented as square 2D arrays.
# They are rotated around their centers.
SHAPES = [
  #   nil nil nil nil
  #   1   1   1   1
  #   nil nil nil nil
  #   nil nil nil nil
  {
    shape: :i,
    minos: [[nil, nil, 1, nil]] * 4,
    color: [0, 200, 200]
  },
  #   1   nil nil
  #   1   1   1
  #   nil nil nil
  {
    shape: :j,
    minos: [[nil, 1, 1], [nil, 1, nil], [nil, 1, nil]],
    color: [0, 0, 255]
  },
  #   nil nil 1
  #   1   1   1
  #   nil nil nil
  {
    shape: :l,
    minos: [[nil, 1, nil], [nil, 1, nil], [nil, 1, 1]],
    color: [255, 165, 0]
  },
  #   1   1
  #   1   1
  {
    shape: :o,
    minos: [[1, 1], [1, 1]],
    color: [255, 255, 0]
  },
  #   nil 1   1
  #   1   1   nil
  #   nil nil nil
  {
    shape: :s,
    minos: [[nil, 1, nil], [nil, 1, 1], [nil, nil, 1]],
    color: [0, 255, 0]
  },
  #   nil 1   nil
  #   1   1   1
  #   nil nil nil
  {
    shape: :t,
    minos: [[nil, 1, nil], [nil, 1, 1], [nil, 1, nil]],
    color: [148, 0, 211]
  },
  #   1   1   nil
  #   nil 1   1
  #   nil nil nil
  {
    shape: :z,
    minos: [[nil, nil, 1], [nil, 1, 1], [nil, 1, nil]],
    color: [255, 0, 0]
  }
]

class Tetromino
  attr_reader :shape
  attr_accessor *%i[minos color x y rotation age gravity_delay lock_down
                    lock_down_timeout lock_down_extensions hard_dropped]

  def initialize(shape)
    @shape, @minos, @color = shape.values_at(:shape, :minos, :color)

    @x = 5 - (@minos.size / 2).ceil
    @y = 21 - @minos.first.size
    @rotation = 0

    @age = 0
    @gravity_delay = 0

    @lock_down = false
    @lock_down_timeout = LOCK_DOWN_DELAY
    @lock_down_extensions = 0

    @hard_dropped = false
  end

  # Many methods involve iterating over each mino of a tetromino to perform
  # an action (or a check, see #current_tetromino_any?). This method exposes
  # the state (filled or unfilled) and matrix coordinates to a block of your
  # choice, like so:
  #
  #   @current_tetromino.each_with_coords do |mino, x, y|
  #     puts "This cell is #{mino ? 'active' : 'inactive'}"
  #     puts "Cell: [#{x}][#{y}]"
  #   end
  #
  # Note that this iterates over the entire tetromino, including empty spaces,
  # thus the presence of `mino` in the above which will be `nil` or `1`. The L
  # tetromino, for example, looks like this in its array:
  #
  #   nil nil 1
  #   1   1   1
  #   nil nil nil
  def each_with_coords(&block)
    @minos.each_with_index do |col, x|
      col.each_with_index do |mino, y|
        block.call mino, @x + x, @y + y
      end
    end
  end

  # Similar to #each_with_coords, runs a conditional on each mino; returns
  # true if any mino meets that condition.
  def any?(&block)
    @minos.each_with_index.any? do |col, x|
      col.each_with_index.any? do |mino, y|
        block.call mino, @x + x, @y + y
      end
    end
  end

  # See #each_with_coords and #any?
  def none?(&block)
    @minos.each_with_index.all? do |col, x|
      col.each_with_index.none? do |mino, y|
        block.call mino, @x + x, @y + y
      end
    end
  end

  # @return a deep copy of this tetromino
  def clone
    copy = self.class.new({
      shape: @shape,
      minos: @minos.map(&:clone),
      color: @color.clone
    })

    %i[@x @y @rotation @age @gravity_delay @lock_down
       @lock_down_timeout @lock_down_extensions @hard_dropped].each do |attr|
      copy.instance_variable_set(attr, instance_variable_get(attr))
    end

    copy
  end
end

class TetrisGame
  # The random generator is fairly simple: shuffle the pieces and put them in a "bag",
  # draw them in order, then reshuffle when the bag is empty. We keep the bag size > 7
  # so that the queue (next 7 pieces, visible) is always filled up
  def spawn_tetromino
    @bag.concat SHAPES.map { |s| Tetromino.new s }.shuffle if @bag.size < 8

    @current_tetromino = @bag.shift

    reset_gravity_delay GRAVITY_VALUES[@level]
  end

  # Checks if the current tetromino is colliding on either the `:left`,
  # or the `:right`, depending on what is passed in. You an also pass in
  # both, like:
  #
  #   current_tetromino_colliding_x?(:left, :right)
  #
  # ...and it will check if either direction has a collision.
  #
  # @overload current_tetromino_colliding_x?(direction, ...)
  #   @param direction [Symbol] :left or :right
  #   @param direction [Symbol] you may include both for an #any? check
  # @return [Boolean] whether or not a collision is detected on the bottom
  def current_tetromino_colliding_x?(*directions)
    unless directions.all? { |dir| %i[left right].include?(dir) }
      raise ArgumentError, "expected :left or :right"
    end

    directions.any? do |dir|
      @current_tetromino.any? do |mino, x, y|
        mino &&
          ((dir == :left &&
              (x <= 0 || @matrix[x - 1][y])) ||
           (dir == :right &&
              (x >= MATRIX_WIDTH - 1 || @matrix[x + 1][y])))
      end
    end
  end

  # Checks if the current tetronimo is colliding on the bottom.
  # The top is irrelevant for our collision checks as the top of
  # the matrix is open and wall kicks do not use this check.
  #
  # @return [Boolean] whether or not a collision is detected on the bottom
  def current_tetromino_colliding_y?
    @current_tetromino.any? do |mino, x, y|
      mino && (y <= 0 || @matrix[x][y - 1])
    end
  end
end
