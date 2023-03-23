PADDING = 120

class TetrisGame
  def render_main_menu
    render_background

    @args.outputs.labels << [
      {
        text: "welcome. relax.",
        x: PADDING,
        y: @args.grid.h - PADDING,
        size_enum: 20,
        r: 255,
        g: 255,
        b: 255
      },
      {
        text: "press space or A when you're ready.",
        x: @args.grid.w - PADDING,
        y: PADDING,
        size_enum: 4,
        alignment_enum: 2,
        r: 255,
        g: 255,
        b: 255
      },
    ]
  end
end
