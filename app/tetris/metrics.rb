
METRICS = %i[accomodation slope bumpiness max_height min_height
             drought pause surplus readiness presses]

class TetrisGame
  def init_metrics
    @drought = false
    @drought_paused = false

    @metrics = METRICS.map { |metric| { metric => 0 } }.inject(:merge)
    @metrics_totals = (%i[drops tetris_readys pauses] + METRICS).
      map { |metric| { metric => 0 } }.inject(:merge)

    # Tracker for Tetris readiness
    @last_ready = 0
  end

  # Per-frame metrics ran at the end of each game tick.
  def calculate_metrics
    # Height of each column
    @heights = @matrix.map do |col|
      column = col.clone
      column.pop while column.last.nil? && column.size > 0
      column.size
    end

    # Take the min and max of the heights of columns that have a block in them
    %w[min max].each do |m|
      @metrics[:"#{m}_height"] = @heights.select(&:positive?).send m
    end

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
    #    1, 0 => S
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
        when [ 1, 0] then accomodated[:s] = true
        when [-1, 0] then accomodated[:z] = true
        end
      end
    end

    @metrics[:accomodation] = accomodated.size

    # These metrics are calculated in a very similar way. A giant spike in the middle
    # won't affect the average slope all that much, but by taking the absolute value
    # of the difference between adjacent lines when adding them up, you get a metric
    # on how "jagged" or "bumpy" the matrix is.
    @metrics[:slope] = relative_heights.reduce(:+) / 9.0
    @metrics[:bumpiness] = relative_heights.reduce { |l, r| l + r.abs } / 9.0
  end

  def find_row_well(y)
    row = @matrix.map { |col| col[y] }
    row.compact.size == 9 ? row.find_index { |x| x.nil? } : nil
  end
end
