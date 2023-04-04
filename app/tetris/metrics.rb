METRICS = %i[accomodation slope bumpiness max_height min_height
             presses drought pause surplus readiness]

class TetrisGame
  def init_metrics
    @drought = false
    @drought_paused = false

    @metrics = METRICS.map { |metric| { metric => 0 } }.inject(:merge)
    @metrics_totals = (%i[drops tetris_readys droughts pauses] + METRICS).
      map { |metric| { metric => 0 } }.inject(:merge)

    # Tracker for Tetris readiness
    @last_tetris = 0
  end

  # Per-frame metrics ran at the end of each game tick.
  def run_frame_metrics
    calculate_heights

    # Differences between neighboring column heights (e.g. if @matrix[0] is
    # 3 tall and @matrix[1] is 2 tall, relative_heights[0] will be -1)
    relative_heights = @heights.each_cons(2).map { |l, r| r - l }

    # Accomodation checks these relative heights to see if the tetrominos will fit.
    # The possibilities we're looking for are:
    #
    # 2-wide:
    #    0 => O, L, J
    #    1 => Z, T
    #   -1 => S, T
    #    2 => J
    #   -2 => L
    #
    # 3-wide:
    #    0, 0 => T, L, J (only need to set T since L/J are already set by the 2-wide 0 check)
    #    0, 1 => S
    #   -1, 0 => Z
    #
    # An I is always accomodated.

    accomodated = { i: true }

    relative_heights.size.times do |x|
      # 2-wide
      case relative_heights[x]
      when  0 then %i[o l j].each { |shape| accomodated[shape] = true }
      when  1 then %i[z t].each { |shape| accomodated[shape] = true }
      when -1 then %i[s t].each { |shape| accomodated[shape] = true }
      when  2 then accomodated[:j] = true
      when -2 then accomodated[:l] = true
      end

      # 3-wide
      if x < relative_heights.size - 1
        case [relative_heights[x], relative_heights[x + 1]]
        when [ 0, 0] then %i[t l j].each { |shape| accomodated[shape] = true }
        when [ 0, 1] then accomodated[:s] = true
        when [-1, 0] then accomodated[:z] = true
        end
      end
    end

    @metrics[:accomodation] = accomodated.size

    # Slope and bumpiness are very closely related. A giant spike in the middle
    # won't affect the average slope all that much, but by taking the absolute value
    # of the difference between adjacent lines when adding them up, you get a metric
    # on how "jagged" or "bumpy" the matrix is.
    #
    # The absolute value is taken of the slope for display aesthetics, and so that
    # the average represents the amount by which the matrix was sloped throughout the
    # game, e.g. if it is slanted way to the left for half the game then way to the
    # right for the other half, we don't want that to average out to 0.
    @metrics[:slope] = (relative_heights.reduce(:+) / 9.0).abs
    @metrics[:bumpiness] = relative_heights.reduce { |l, r| l + r.abs } / 9.0
  end

  def run_drop_metrics
    calculate_heights

    @metrics_totals[:drops] += 1

    # For tracking frame metrics averages. Every time a tetromino is dropped, the
    # metrics for that frame are added to a total, and the drops are counted.
    %i[accomodation slope bumpiness max_height min_height presses].each do |metric|
      @metrics_totals[metric] += @metrics[metric]
    end

    well_open = nil
    well_x = nil
    @tetris_ready = false

    (MATRIX_HEIGHT - 1).downto(3).each do |y|
      # Find the first row with a well in it, and save the x column
      next unless well_x = find_row_well(y)
      @tetris_ready =
        # If the well extends 3 rows below the one we found, and...
        ((y - 3)..(y - 1)).all? { |y2| find_row_well(y2) == well_x } &&
        # ...if the well is open at the top...
        @heights[well_x] < y &&
        # ...and closed at the bottom, we're Tetris ready!
        (y == 3 || @matrix[well_x][y - 4])

      break if @tetris_ready
    end

    if tetris_scored?
      @last_tetris = @metrics_totals[:drops]

      # #start_drought increments this, even if it's just because an I spawned;
      # if we use the I right away to score a Tetris, we don't want it to count
      # a 0 onto the drought average, so decrement it. Otherwise, we'll allow
      # the drought to count
      @metrics_totals[:droughts] -= 1
    end

    # See the flowchart in `docs/` for a visual of the logic in this block
    if @drought
      if @drought_paused
        if @tetris_ready
          @drought_paused = false
        else
          @metrics[:pause] += 1
          @metrics_totals[:pause] += 1
        end
      else
        # Not paused
        if @tetris_ready
          if tetris_scored?
            # Start a new drought in the case that a Tetris has been
            # scored, but the matrix is still Tetris ready
            start_drought still_ready: true
          else
            @metrics[:drought] += 1
            @metrics_totals[:drought] += 1
          end
        else
          if tetris_scored?
            @drought = false
          else
            @drought_paused = true
            @metrics[:pause] = 0
            @metrics_totals[:pauses] += 1
          end
        end
      end
    elsif @tetris_ready
      start_drought

      # Surplus is the blocks that would remain if the Tetris were to be made immediately.
      # To find this, we need to find the bottom of the well.
      well_bottom = @matrix[well_x].find_index(&:nil?) || 0

      @metrics[:surplus] = @matrix.map do |col|
        (col[-1...well_bottom] + (col[(well_bottom + 4)..-1] || [])).compact.size
      end.inject(:+)

      @metrics_totals[:tetris_readys] += 1
      @metrics_totals[:readiness] += @metrics[:readiness]
      @metrics_totals[:surplus] += @metrics[:surplus]
    end
  end

  def start_drought(spawn_reset: false, still_ready: false)
    @drought = true
    @metrics[:drought] = 0
    @metrics_totals[:droughts] += 1

    unless spawn_reset
      if still_ready
        @metrics_totals[:tetris_readys] += 1
        @metrics[:readiness] = 0
      else
        @metrics[:readiness] = @metrics_totals[:drops] - @last_tetris
      end
    end

    # Force this otherwise it will take an extra drop to register in the UI
    @tetris_ready = true
  end

  def calculate_heights
    @heights = @matrix.map do |col|
      column = col.clone
      column.pop while column.last.nil? && column.size > 0
      column.size
    end

    # Take the min and max of the heights of columns that have a block in them
    %w[min max].each do |m|
      @metrics[:"#{m}_height"] = @heights.select(&:positive?).send(m) || 0
    end
  end

  def find_row_well(y)
    row = @matrix.map { |col| col[y] }
    row.compact.size == 9 ? row.find_index { |x| x.nil? } : nil
  end
end
