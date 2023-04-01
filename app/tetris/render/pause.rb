# frozen_string_literal: true

class TetrisGame
  def render_pause
    render_background
    render_stats

    render_main_menu_text
    render_corner_text "it's okay. gather your thoughts.",
                       ["#{advance_button} to continue",
                        "#{controller_connected? ? 'Y' : 'C'} for controls",
                        "#{controller_connected? ? 'X' : 'M'} to toggle music",
                        "#{controller_connected? ? 'select' : 'enter'} to restart"]
  end
end
