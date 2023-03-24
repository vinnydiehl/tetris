class TetrisGame
  def render_controls
    render_background
    render_corner_text "controls", "#{controller_connected? ? "B" : "escape"} to go back"

    if controller_connected?
      @args.outputs.labels << [
        {
          text: "D-Pad or analog stick to move side-to-side",
          x: @args.grid.w / 2,
          y: 460,
          size_enum: 1,
          alignment_enum: 1,
          r: 255,
          g: 255,
          b: 255
        },
        {
          text: "L and R to rotate",
          x: @args.grid.w / 2,
          y: 420,
          size_enum: 1,
          alignment_enum: 1,
          r: 255,
          g: 255,
          b: 255
        },
        {
          text: "D-Pad up or A to hard drop",
          x: @args.grid.w / 2,
          y: 380,
          size_enum: 1,
          alignment_enum: 1,
          r: 255,
          g: 255,
          b: 255
        },
        {
          text: "down to soft drop",
          x: @args.grid.w / 2,
          y: 340,
          size_enum: 1,
          alignment_enum: 1,
          r: 255,
          g: 255,
          b: 255
        },
        {
          text: "X or Y to hold",
          x: @args.grid.w / 2,
          y: 300,
          size_enum: 1,
          alignment_enum: 1,
          r: 255,
          g: 255,
          b: 255
        },
        {
          text: "start to pause",
          x: @args.grid.w / 2,
          y: 260,
          size_enum: 1,
          alignment_enum: 1,
          r: 255,
          g: 255,
          b: 255
        }
      ]
    else
      width = 1000
      height = 449

      @args.outputs.sprites << {
        x: @args.grid.w / 2 - width / 2,
        y: @args.grid.h / 2 - height / 2,
        w: width,
        h: height,
        path: "sprites/controls/keyboard.png"
      }
    end
  end
end
