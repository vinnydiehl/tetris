# frozen_string_literal: true

class TetrisGame
  def render_controls
    render_background
    render_corner_text "controls", "#{controller_connected? ? 'B' : 'escape'} to go back"

    if controller_connected?
      @args.outputs.labels << [
        "D-Pad or analog stick to move side-to-side",
        "L and R to rotate",
        "D-Pad up or A to hard drop",
        "down to soft drop",
        "X or Y to hold",
        "start to pause"
      ].span_vertically(@args.grid.w / 2, 460, 40, alignment: :center)
    else
      width = 1000
      height = 449

      @args.outputs.sprites << {
        x: (@args.grid.w / 2) - (width / 2),
        y: (@args.grid.h / 2) - (height / 2),
        w: width,
        h: height,
        path: "sprites/controls/keyboard.png"
      }
    end
  end
end

