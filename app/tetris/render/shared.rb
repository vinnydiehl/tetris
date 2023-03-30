class String
  # Creates a label primitive with the given options.
  #
  # @param options [Hash] options to feed to the primitive
  # @option options [Integer] :x x-coordinate in pixels
  # @option options [Integer] :y y-coordinate in pixels
  # @option options [Integer] :size the size of the text
  # @option options [Symbol] :alignment :left, :center, or :right
  # @option options [Integer] :r RGBa red value
  # @option options [Integer] :g RGBa green value
  # @option options [Integer] :b RGBa blue value
  # @option options [Integer] :a RGBa alpha value
  def label(**options)
    %i[x y].each do |required_opt|
      raise ArgumentError, ":#{required_opt} option required" unless required_opt
    end

    options.keys.each do |option|
      if option.include? "_enum"
        raise ArgumentError, "try :#{option.to_s.split("_").first} instead of :#{option}"
      end
    end

    if options[:alignment].is_a?(Symbol)
      options[:alignment] = {left: 0, center: 1, right: 2}[options[:alignment]]
    end

    {
      text: self,
      x: options[:x],
      y: options[:y],
      size_enum: options[:size] || 1,
      alignment_enum: options[:alignment] || 0,
      r: options[:r] || 255,
      g: options[:g] || 255,
      b: options[:b] || 255,
      a: options[:a] || 255
    }
  end
end

class Array
  # Span an array of strings into several labels with even spacing.
  #
  # @param options [Hash] options to feed to the primitive
  # @option options [Integer] :x x-coordinate in pixels of the top label
  # @option options [Integer] :y y-coordinate in pixels
  # @option options [Integer] :spacing the space in pixels between the labels
  # @option options [Integer] :size the size of the text
  # @option options [Symbol] :alignment :left, :center, or :right
  # @option options [Integer] :r RGBa red value
  # @option options [Integer] :g RGBa green value
  # @option options [Integer] :b RGBa blue value
  # @option options [Integer] :a RGBa alpha value
  def span_vertically(**options)
    %i[x y spacing].each do |required_opt|
      raise ArgumentError, ":#{required_opt} option required" unless required_opt
    end

    # String#label would do this anyway, but it's more efficient to do it here
    if options[:alignment].is_a?(Symbol)
      options[:alignment] = {left: 0, center: 1, right: 2}[options[:alignment]]
    end

    each_with_index.map do |str, i|
      next if str.nil? || str.empty?

      str.label x: options[:x],
                y: options[:y] - options[:spacing] * i,
                size: options[:size],
                alignment: options[:alignment],
                r: options[:r],
                g: options[:g],
                b: options[:b]
    end.compact
  end
end

class TetrisGame
  def render_background
    @args.outputs.solids << [0, 0, 1280, 720, 0, 0, 0]
  end

  # Renders the text seen in the corners of all of the menus.
  #
  # @overload render_corner_text(upper_left, lower_right)
  #   @param upper_left [String] text to display in the upper left
  #   @param lower_right [String] text to display in the lower right
  # @overload render_corner_text(upper_left, lower_right)
  #   @param upper_left [String] text to display in the upper left
  #   @param lower_right [Array] text to display in the lower right, stacked vertically
  #
  # @param options [Hash] additional options
  # @option options [Integer] :size custom size for the text in the upper left
  def render_corner_text(upper_left, lower_right, **options)
    @args.outputs.labels << [
      upper_left.label(x: PADDING, y: @args.grid.h - PADDING + 20, size: options[:size] || 20),
      lower_right.is_a?(Array) ?
        lower_right.span_vertically(spacing: 32, size: 4, alignment: :right,
          x: @args.grid.w - PADDING, y: PADDING + 32 * (lower_right.size - 1)) :
        lower_right.label(x: @args.grid.w - PADDING, y: PADDING, size: 4, alignment: :right)
    ]
  end

  def render_main_menu_text
    @args.outputs.labels << "#{controller_connected? ? "L + R" : "m"} for main menu".label(
      x: PADDING, y: PADDING, size: 4)
  end

  def render_stats
    @args.outputs.labels << [
      "Time: #{time_elapsed}",
      "Score: #{@score}",
      "Lines: #{@lines} (#{@actual_lines_cleared} actual)",
      "Level: #{@level}",
      "SPM: #{score_per_minute}",
      "LPM: #{lines_per_minute}",
      "BRN: #{@burnt_lines}",
      "TRT: #{tetris_rate}",
      "Tetrises: #{(@tetris_lines / 4).floor}",
      "T-Spins: #{@t_spins_scored}#{@mini_t_spins_scored > 0 ? " (+ #{@mini_t_spins_scored} mini)" : ''}",
      "Best Streak: #{@highest_streak}"
    ].span_vertically(x: @args.grid.w / 2, y: 500, spacing: 30, alignment: :center)
  end

  def controller_connected?
    @args.inputs.controller_one.connected
  end

  def advance_button
    controller_connected? ? "A" : "space"
  end
end
