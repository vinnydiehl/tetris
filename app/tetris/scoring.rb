class TetrisGame
  def clear_lines
    @lines_cleared_this_frame = 0

    MATRIX_HEIGHT.times.reverse_each do |y|
      if @matrix.all? { |col| col[y] }
        @lines_cleared_this_frame += 1

        @matrix.each do |col|
          col.delete_at y
        end
      end
    end
  end

  def handle_scoring
    if @lines_cleared_this_frame > 0 || @t_spin
      points, sound = {
        [:full, 3] => [1600, "t_spin_triple"],
        [:full, 2] => [1200, "t_spin_double"],
        [:full, 1] => [800,  "t_spin_single"],
        [:full, 0] => [400,  "t_spin"],
        [:mini, 2] => [500,  "t_spin_double"],
        [:mini, 1] => [200,  "t_spin_single"],
        [:mini, 0] => [100,  "t_spin"],
        [nil,   4] => [800,  "tetris"],
        [nil,   3] => [500,  "triple"],
        [nil,   2] => [300,  "double"],
        [nil,   1] => [100,  "single"]
      }[[@t_spin, @lines_cleared_this_frame]]

      play_sound_effect "score/#{sound}"

      # All Clear bonus
      if @matrix.all? { |col| col.none? }
        points += 400
        delay 30 { play_sound_effect "score/all_clear" }
      end

      # Process back-to-back bonus. A single, double, or triple
      # line clear will end a back-to-back streak
      if @t_spin || @lines_cleared_this_frame == 4
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
      @lines += (points / 100).floor

      # This formula starts it at 5 lines to increment to level 2,
      # then 10 more lines to increment to level 3, then 15, then
      # 20; 5 is added to the increment each time. Level 15 is reached
      # at 600 lines.
      old_level = @level
      @level = (1..Float::INFINITY).lazy.map { |i| (i * (i + 1) / 2) * 5 }.
        take_while { |lines| lines <= @lines }.count + 1

      if @level > old_level
        delay 30 { play_sound_effect "score/level_up" }
      end

      # Note that @lines_cleared_this_frame was never directly added to @lines,
      # instead being processed along with the score. We do need to save some
      # more data before we get rid of it:
      @actual_lines_cleared += @lines_cleared_this_frame

      if @lines_cleared_this_frame == 4
        @tetris_lines += 4
      elsif !@t_spin
        @burnt_lines += @lines_cleared_this_frame
      end

      # Reset everything for next frame
      @lines_cleared_this_frame = 0
      @t_spin = nil
    end
  end

  def time_elapsed
    seconds = @timer / FPS
    minutes, seconds = seconds.divmod(60)
    hours, minutes = minutes.divmod(60)
    milliseconds = (@timer % FPS) * 1000 / FPS

    "#{hours > 0 ? "%.2d:" % hours : ""}#{"%.2d" % minutes}:#{"%.2d" % seconds}.#{"%.3d" % milliseconds}"
  end

  def minutes_elapsed
    minutes_elapsed = @timer / 60 / 60
  end

  def tetris_rate
    @actual_lines_cleared == 0 ? 0 :
      format_percent(@tetris_lines / @actual_lines_cleared * 100)
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

    str + "%"
  end
end
