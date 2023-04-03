class TetrisGame
  def check_line_clear
    @lines_cleared_this_frame = []

    MATRIX_HEIGHT.times.each do |y|
      if @matrix.all? { |col| col[y] }
        @lines_cleared_this_frame << y

        @matrix.each_with_index do |col, x|
          @animation_matrix[x][y] = col[y]
          col[y] = nil
        end
      end
    end

    if @lines_cleared_this_frame.size > 0 && !animating?(:line_clear)
      begin_animation :line_clear
    end
  end

  def handle_scoring
    lines_cleared = @lines_cleared_this_frame.size

    if lines_cleared > 0 || @t_spin
      points, type = {
        [:full, 3] => [1600, :t_spin_triple],
        [:full, 2] => [1200, :t_spin_double],
        [:full, 1] => [800,  :t_spin_single],
        [:full, 0] => [400,  :t_spin],
        [:mini, 2] => [500,  :mini_t_spin_double],
        [:mini, 1] => [200,  :mini_t_spin_single],
        [:mini, 0] => [100,  :mini_t_spin],
        [nil,   4] => [800,  :tetris],
        [nil,   3] => [500,  :triple],
        [nil,   2] => [300,  :double],
        [nil,   1] => [100,  :single]
      }[[@t_spin, lines_cleared]]

      @clears[type] += 1

      # Mini T-Spins make the same sound as regular ones
      play_sound_effect "score/#{type.to_s.delete 'mini_'}"

      # All Clear bonus
      if @matrix.all?(&:none?)
        points += 400
        @clears[:all_clear] += 1
        delay(30) { play_sound_effect "score/all_clear" }
      end

      # Process back-to-back bonus. A single, double, or triple
      # line clear will end a back-to-back streak
      if @t_spin || lines_cleared == 4
        points *= 1.5 if @back_to_back > 0
        @back_to_back += 1

        if @back_to_back > @highest_streak
          @highest_streak = @back_to_back
          @new_best_set = true
        end
      else
        @back_to_back = 0
        @new_best_set = false
      end

      @score += (points * @level).floor

      lines_rewarded = (points / 100).floor
      @lines += lines_rewarded
      @lines_needed -= lines_rewarded

      check_level

      # Note that lines_cleared was never directly added to @lines,
      # instead being processed along with the score. We do need to save some
      # more data before we get rid of it:
      @actual_lines_cleared += lines_cleared

      # This is saved so that lines cleared from T-Spins don't hurt TRT
      @t_spin_lines_cleared += lines_cleared if @t_spin

      if lines_cleared < 4 && !@t_spin
        @burnt_lines += lines_cleared
      end

      # Reset this for next frame; @lines_cleared_this_frame is reset in the animation
      @t_spin = nil
    end
  end

  # It starts at 5 lines to increment to level 2, then 10 more lines to increment
  # to level 3, then 15, then 20; 5 is added to the increment each time. Level 15
  # is reached at 600 lines. If you start at a higher level you will need the
  # appropriate # of lines to advance that level, e.g. if you start at level 3 you
  # will need 15 lines.
  def check_level
    if @lines_needed <= 0
      @level += 1
      set_lines_needed
      delay(30) { play_sound_effect "score/level_up" }
    end
  end

  # Sets the lines needed for the next level
  def set_lines_needed
    # If @lines_needed has gone into the negative, need to add it back to the new total
    @lines_needed = (@level * 5) + @lines_needed
  end

  def time_elapsed
    seconds = @timer / FPS
    minutes, seconds = seconds.divmod(60)
    hours, minutes = minutes.divmod(60)
    milliseconds = (@timer % FPS) * 1000 / FPS

    "#{hours > 0 ? '%.2d:' % hours : ''}#{'%.2d' % minutes}:#{'%.2d' % seconds}.#{'%.3d' % milliseconds}"
  end

  def minutes_elapsed
    @timer / 60 / 60
  end

  def tetris_rate
    @actual_lines_cleared == 0 ? 0 :
      format_percent(@clears[:tetris] * 4 / (@actual_lines_cleared - @t_spin_lines_cleared) * 100)
  end

  def score_per_minute
    minutes_elapsed == 0 ? 0 : (@score / minutes_elapsed).floor
  end

  def lines_per_minute
    @lines.zero? ? "0" : "%.02f" % (@lines / minutes_elapsed)
  end

  def format_percent(number)
    str = "%.2f" % number
    2.times { str.chop! if str[-1] == "0" }
    str.chop! if str[-1] == "."

    "#{str}%"
  end
end
