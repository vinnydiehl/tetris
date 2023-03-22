class TetrisGame
  def count_line_clears
    @lines_cleared_this_frame = MATRIX_HEIGHT.times.count do |y|
      @matrix.all? { |col| col[y] }
    end

    # This method runs asynchronously to the score handling; there
    # are a few frames where the score will have been applied, the
    # lines are still in the process of clearing, and they will be
    # counted for that frame. This lock prevents those points
    # from being counted again, and once the lines are back to 0
    # we remove the lock:
    @score_applied = false if @lines_cleared_this_frame == 0
  end

  def clear_lines
    MATRIX_HEIGHT.times do |y|
      if @matrix.all? { |col| col[y] }
        @matrix.each do |col|
          col.delete_at y
        end
      end
    end
  end

  def handle_scoring
    if !@score_applied && (@lines_cleared_this_frame > 0 || @t_spin)
      points =
        @t_spin == :full && @lines_cleared_this_frame == 3 ? 1600 :
        @t_spin == :full && @lines_cleared_this_frame == 2 ? 1200 :
        (@t_spin == :full && @lines_cleared_this_frame == 1) ||
          @lines_cleared_this_frame == 4 ? 800 :
        @lines_cleared_this_frame == 3 ? 500 :
        @t_spin == :full ? 400 :
        @lines_cleared_this_frame == 2 ? 300 :
        @t_spin == :mini && @lines_cleared_this_frame == 1 ? 200 : 100

      @args.state.lines_cleared_this_frame =  [@args.state.lines_cleared_this_frame || 0, @lines_cleared_this_frame].max

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
      @lines_cleared += (points / 100).floor

      # This formula starts it at 5 lines to increment to level 2,
      # then 10 more lines to increment to level 3, then 15, then
      # 20; 5 is added to the increment each time. Level 15 is reached
      # at 600 lines.
      @level = (1..Float::INFINITY).lazy.map { |i| (i * (i + 1) / 2) * 5 }.
        take_while { |lines| lines <= @lines_cleared }.count + 1

      # Reset these
      @lines_cleared_this_frame = 0
      @t_spin = nil

      # Lock to prevent the same score event from being counted
      # multiple frames in a row
      @score_applied = true
    end
  end
end
