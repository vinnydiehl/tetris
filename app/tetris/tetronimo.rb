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
  attr_accessor *%i[minos color x y rotation age gravity_delay
                    lock_down last_movement lock_down_timeout
                    lock_down_extensions hard_dropped soft_dropping]

  def initialize(shape)
    @shape, @minos, @color = shape.values_at(:shape, :minos, :color)

    @x = 5 - (@minos.size / 2).ceil
    @y = 21 - @minos.first.size
    @rotation = 0

    # This is recorded for the purpose of recognizing T-Spins; it will
    # be set to either :gravity or the kick test used to rotate the piece
    @last_movement = nil

    @age = 0
    @gravity_delay = 0

    @lock_down = false
    @lock_down_timeout = LOCK_DOWN_DELAY
    @lock_down_extensions = 0
    @extension_reset_allowed = true

    @hard_dropped = false
    @soft_dropping = false
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
  #
  # @param in_x [Integer] optional custom x coordinate
  # @param in_y [Integer] optional custom y coordinate
  def each_with_coords(in_x=@x, in_y=@y, &block)
    @minos.each_with_index do |col, x|
      col.each_with_index do |mino, y|
        block.call mino, in_x + x, in_y + y
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
  def all?(&block)
    @minos.each_with_index.all? do |col, x|
      col.each_with_index.all? do |mino, y|
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

  # This determines whether or not the piece is allowed to reset its delay
  # extensions upon moving downward. Once a piece is rotated such that its
  # lowest point moves upward, this flag is disabled for the remainder of
  # the tetromino's time in play.
  def extension_reset_allowed?
    @extension_reset_allowed
  end

  # Disable the extension reset as discussed above
  def disable_extension_reset
    @extension_reset_allowed = false
  end

  # @return the lowest y-coordinate on the matrix that the tetromino occupies
  def lowest_y
    ys = []
    each_with_coords { |mino, _, y| ys << y if mino }
    ys.min
  end

  # @return a deep copy of this tetromino
  def clone
    copy = self.class.new({
      shape: @shape,
      minos: @minos.map(&:clone),
      color: @color.clone
    })

    %i[@x @y @rotation @age @gravity_delay @lock_down
       @extension_reset_allowed @last_movement @lock_down_timeout
       @lock_down_extensions @hard_dropped @soft_dropping].each do |attr|
      copy.instance_variable_set(attr, instance_variable_get(attr))
    end

    copy
  end
end

class TetrisGame
  # The random generator is fairly simple: shuffle the pieces and put them in a "bag",
  # draw them in order, then reshuffle when the bag is empty. We keep the bag size > 7
  # so that the queue (next 7 pieces, visible) is always filled up
  #
  # @param tetromino [Tetromino] optional tetromino to spawn instead of using the bag
  def spawn_tetromino(tetromino=nil)
    # Make sure the bag is full every time we spawn
    if !tetromino && @bag.size < 8
      # Use this for debugging; change the index to get only that shape
      # @bag.concat ([SHAPES[0]] * 7).map { |s| Tetromino.new s }.shuffle

      @bag.concat SHAPES.map { |s| Tetromino.new s }.shuffle
    end

    @current_tetromino = tetromino || @bag.shift

    if @current_tetromino.any? { |mino, x, y| mino && @matrix[x][y] }
      begin_animation :game_over
    end

    reset_gravity_delay GRAVITY_VALUES[@level]
    @hold_available = true
    @spawning = false
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

  def hold_current_tetromino
    hold_shape = @current_tetromino.shape.clone

    if @held_tetromino
      spawn_tetromino @held_tetromino
      @held_tetromino = Tetromino.new(SHAPES.find { |s| s[:shape] == hold_shape })
    else
      @held_tetromino = Tetromino.new(SHAPES.find { |s| s[:shape] == hold_shape })
      spawn_tetromino
    end

    @hold_available = false
  end
end
