class TetrisGame
  def render_game_over
    render_background
    render_stats
    render_corner_text "you lose. :(", "press #{advance_button} to go again"
  end
end
