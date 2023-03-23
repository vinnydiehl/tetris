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
      points =
        @t_spin == :full && @lines_cleared_this_frame == 3 ? 1600 :
        @t_spin == :full && @lines_cleared_this_frame == 2 ? 1200 :
        (@t_spin == :full && @lines_cleared_this_frame == 1) ||
          @lines_cleared_this_frame == 4 ? 800 :
        @lines_cleared_this_frame == 3 ? 500 :
        @t_spin == :full ? 400 :
        @lines_cleared_this_frame == 2 ? 300 :
        @t_spin == :mini && @lines_cleared_this_frame == 1 ? 200 : 100

      # All Clear bonus
      if @matrix.all? { |col| col.none? }
        points += 400
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
      @level = (1..Float::INFINITY).lazy.map { |i| (i * (i + 1) / 2) * 5 }.
        take_while { |lines| lines <= @lines }.count + 1

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
end
