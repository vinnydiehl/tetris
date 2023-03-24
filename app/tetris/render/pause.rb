class TetrisGame
  def render_pause
    render_background
    render_stats

    render_corner_text "it's okay. gather your thoughts.",
      "press #{controller_connected? ? "select" : "enter"} to restart"

    @args.outputs.labels << {
      text: "press #{advance_button} to continue",
      x: @args.grid.w - PADDING,
      y: PADDING + 32,
      size_enum: 4,
      alignment_enum: 2,
      r: 255,
      g: 255,
      b: 255
    }
  end
end
