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
  # @option :size [Integer] custom size for the text in the upper left
  def render_corner_text(upper_left, lower_right, size: 20)
    @args.outputs.labels << [
      upper_left.label(PADDING, @args.grid.h - PADDING + 20, size: size),
      if lower_right.is_a?(Array)
        lower_right.span_vertically(@args.grid.w - PADDING, PADDING + (32 * (lower_right.size - 1)),
                                    32, size: 4, alignment: :right)
      else
        lower_right.label(@args.grid.w - PADDING, PADDING, size: 4, alignment: :right)
      end
    ]
  end

  def render_main_menu_text
    @args.outputs.labels << "#{controller_connected? ? 'L + R' : 'backspace'} for main menu".label(
      PADDING, PADDING, size: 4)
  end

  def render_stats
    t_spins_scored = @clears.select { |k, _| k.to_s.start_with? "t_spin" }.values.inject(:+)
    mini_t_spins_scored = @clears.select { |k, _| k.to_s.start_with? "mini_t_spin" }.values.inject(:+)

    # Center labels
    labels = [
      "Time: #{time_elapsed}",
      "Score: #{@score}",
      "Lines: #{@lines} (#{@actual_lines_cleared} actual)",
      "Level: #{@level}",
      "SPM: #{score_per_minute}",
      "LPM: #{lines_per_minute}",
      "BRN: #{@burnt_lines}",
      "TRT: #{tetris_rate}",
      "Best Streak: #{@highest_streak}"
    ].span_vertically(@args.grid.w / 2, 480, 30, size: 3, alignment: :center)

    # Clears table

    labels << "Lines".label(120, 460, size: 5, alignment: :center)
    labels << [
      "Single: #{@clears[:single]}",
      "Double: #{@clears[:double]}",
      "Triple: #{@clears[:triple]}",
      "Tetris: #{@clears[:tetris]}",
      "All Clear: #{@clears[:all_clear]}"
    ].span_vertically(120, 410, 30, size: 0.2, alignment: :center)

    labels << "T-Spins".label(250, 460, size: 5, alignment: :center)
    labels << [
      "T-Spin: #{@clears[:t_spin]}",
      "Single: #{@clears[:t_spin_single]}",
      "Double: #{@clears[:t_spin_double]}",
      "Triple: #{@clears[:t_spin_triple]}"
    ].span_vertically(250, 410, 30, size: 0.2, alignment: :center)

    labels << "Mini".label(380, 460, size: 5, alignment: :center)
    labels << [
      "Mini: #{@clears[:mini_t_spin]}",
      "Single: #{@clears[:mini_t_spin_single]}",
      "Double: #{@clears[:mini_t_spin_double]}"
    ].span_vertically(380, 410, 30, size: 0.2, alignment: :center)

    # Metrics averages (only displayed after first drop)

    if @metrics_totals[:drops] > 0
      labels << "Averages".label(1030, 460, size: 5, alignment: :center)

      labels << [
        "Accomodation: %.01f" % (@metrics_totals[:accomodation] / @metrics_totals[:drops]),
        "Slope: %.01f" % (@metrics_totals[:slope] / @metrics_totals[:drops]),
        "Bumpiness: %.01f" % (@metrics_totals[:bumpiness] / @metrics_totals[:drops]),
        "Max Height: %.01f" % (@metrics_totals[:max_height] / @metrics_totals[:drops]),
        "Min Height: %.01f" % (@metrics_totals[:min_height] / @metrics_totals[:drops])
      ].span_vertically(940, 410, 30, size: 0.2, alignment: :center)

      labels << [
        "Presses: %.01f" % (@metrics_totals[:presses] / @metrics_totals[:drops]),
        "Drought: #{@metrics_totals[:droughts].zero? ? 'N/A' : '%.01f' % (@metrics_totals[:drought] / @metrics_totals[:droughts])}",
        "Pause: #{@metrics_totals[:pauses].zero? ? 'N/A' : '%.01f' % (@metrics_totals[:pause] / @metrics_totals[:pauses])}",
        "Surplus: #{@metrics_totals[:tetris_readys].zero? ? 'N/A' : '%.01f' % (@metrics_totals[:surplus] / @metrics_totals[:tetris_readys])}",
        "Readiness: #{@metrics_totals[:tetris_readys].zero? ? 'N/A' : '%.01f' % (@metrics_totals[:readiness] / @metrics_totals[:tetris_readys])}"
      ].span_vertically(1140, 410, 30, size: 0.2, alignment: :center)
    end

    @args.outputs.labels << labels
  end

  def controller_connected?
    @args.inputs.controller_one.connected
  end

  def advance_button
    controller_connected? ? "A" : "space"
  end
end
