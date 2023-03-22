class TetrisGame
  def clear_lines
    @lines_cleared_this_frame = 0

    MATRIX_HEIGHT.times do |y|
      if @matrix.all? { |col| col[y] }
        @lines_cleared_this_frame += 1

        # Delete the line
        @matrix.each { |col| col[y] = nil }

        # Shift everything above it downward
        @matrix.each do |col|
          (y..MATRIX_HEIGHT-1).each do |y|
            col[y] = col[y + 1]
          end
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

      points *= 1.5 if @back_to_back_active

      @score += (points * @level).floor
      @lines_cleared += (points / 100).floor

      # This formula starts it at 5 lines to increment to level 2,
      # then 10 more lines to increment to level 3, then 15, then
      # 20; 5 is added to the increment each time. Level 15 is reached
      # at 600 lines.
      @level = (1..Float::INFINITY).lazy.map { |i| (i * (i + 1) / 2) * 5 }.
        take_while { |lines| lines <= @lines_cleared }.count + 1

      # Only a single, double, or triple line clear will end a back-to-back streak
      @back_to_back_active = @t_spin || @lines_cleared_this_frame == 4

      # Reset these
      @lines_cleared_this_frame = 0
      @t_spin = nil
    end
  end
end
