class TetrisGame
  def render_main_menu
    render_background

    render_corner_text "relax. take a deep breath.", "press #{advance_button} when you're ready."

    @args.outputs.labels << {
      text: "press #{controller_connected? ? "start" : "escape"} for controls.",
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
