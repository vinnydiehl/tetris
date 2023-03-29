class TetrisGame
  def render_game_over
    render_background
    render_stats

    render_main_menu_text
    render_corner_text "congratulations. you are a Tetris master.",
                       "press #{advance_button} to go again", size: 12
  end
end
