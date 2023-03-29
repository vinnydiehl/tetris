class TetrisGame
  def render_main_menu
    render_background

    render_corner_text "relax. take a deep breath.", "press #{advance_button} when you're ready."

    @args.outputs.labels <<
      "press #{controller_connected? ? "start" : "escape"} for controls.".label(
        x: @args.grid.w - PADDING, y: PADDING + 32,
        size: 4, alignment: :right
      )

    render_level_selector
  end

  def render_level_selector
    @args.outputs.sprites << [
      {
        path: "sprites/ui/chevron.png",
        x: 140,
        y: 140,
        w: 35,
        h: 50,
        angle: 90,
        a: 100
      },
      {
        path: "sprites/ui/chevron.png",
        x: 140,
        y: 60,
        w: 35,
        h: 50,
        angle: 270,
        a: 100
      }
    ]

    @args.outputs.labels << [
      @starting_level.to_s.label(x: 159, y: 145, size: 8, alignment: :center),
      %w[choose level].span_vertically(x: 200, y: 150, spacing: 25)
    ]
  end
end
