ARROW_ALPHA = 100
ARROW_BRIGHT_ALPHA = 200

class TetrisGame
  def main_menu_ui_init
    @selector_buttons = [
      {
        path: "sprites/ui/chevron.png",
        x: 140,
        y: 140,
        w: 35,
        h: 50,
        angle: 90,
        a: ARROW_ALPHA,
        value: 1
      },
      {
        path: "sprites/ui/chevron.png",
        x: 140,
        y: 60,
        w: 35,
        h: 50,
        angle: 270,
        a: ARROW_ALPHA,
        value: -1
      }
    ]
  end

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
    @args.outputs.sprites << @selector_buttons

    @args.outputs.labels << [
      @starting_level.to_s.label(x: 159, y: 145, size: 8, alignment: :center,
        a: 77.5 * Math.sin(0.03 * (@args.state.tick_count - @selector_last_clicked) + 1.6) + 177.5),
      %w[choose level].span_vertically(x: 200, y: 150, spacing: 25)
    ]
  end
end
