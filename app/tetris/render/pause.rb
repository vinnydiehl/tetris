class TetrisGame
  def render_pause
    render_background
    render_stats

    render_main_menu_text
    render_corner_text "it's okay. gather your thoughts.",
      "#{controller_connected? ? "select" : "enter"} to restart"

    @args.outputs.labels << [
      "#{advance_button} to continue",
      "#{controller_connected? ? "Y" : "C"} for controls",
    ].span_vertically(
      x: @args.grid.w - PADDING, y: PADDING + 64,
      spacing: 32, size: 4, alignment: :right
    )
  end
end
