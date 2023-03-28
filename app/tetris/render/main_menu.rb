class TetrisGame
  def render_main_menu
    render_background

    render_corner_text "relax. take a deep breath.", "press #{advance_button} when you're ready."

    @args.outputs.labels <<
      "press #{controller_connected? ? "start" : "escape"} for controls.".label(
        x: @args.grid.w - PADDING, y: PADDING + 32,
        size: 4, alignment: :right
      )
  end
end
