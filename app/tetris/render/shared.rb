PADDING = 120

class TetrisGame
  def render_background
    @args.outputs.solids << [0, 0, 1280, 720, 0, 0, 0]
  end

  def render_corner_text(upper_left, lower_right)
    @args.outputs.labels << [
      {
        text: upper_left,
        x: PADDING,
        y: @args.grid.h - PADDING + 20,
        size_enum: 20,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: lower_right,
        x: @args.grid.w - PADDING,
        y: PADDING,
        size_enum: 4,
        alignment_enum: 2,
        r: 255,
        g: 255,
        b: 255
      }
    ]
  end

  def render_stats
    @args.outputs.labels << [
      {
        text: "Time: #{time_elapsed}",
        x: @args.grid.w / 2,
        y: 500,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "Score: #{@score}",
        x: @args.grid.w / 2,
        y: 470,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "Lines: #{@lines} (#{@actual_lines_cleared} actual)",
        x: @args.grid.w / 2,
        y: 440,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "Level: #{@level}",
        x: @args.grid.w / 2,
        y: 410,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "SPM: #{score_per_minute}",
        x: @args.grid.w / 2,
        y: 380,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "LPM: #{lines_per_minute}",
        x: @args.grid.w / 2,
        y: 350,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "BRN: #{@burnt_lines}",
        x: @args.grid.w / 2,
        y: 320,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "TRT: #{tetris_rate}",
        x: @args.grid.w / 2,
        y: 290,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "Tetrises: #{(@tetris_lines / 4).floor}",
        x: @args.grid.w / 2,
        y: 260,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "T-Spins: #{@t_spins_scored}#{@mini_t_spins_scored > 0 ? " (+ #{@mini_t_spins_scored} mini)" : ''}",
        x: @args.grid.w / 2,
        y: 230,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "Best Streak: #{@highest_streak}",
        x: @args.grid.w / 2,
        y: 200,
        size_enum: 1,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
      }
    ]
  end

  def controller_connected?
    @args.inputs.controller_one.connected
  end

  def advance_button
    controller_connected? ? "A" : "space"
  end
end
