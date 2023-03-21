class TetrisGame
  def clear_lines
    lines_cleared = 0

    MATRIX_HEIGHT.times do |y|
      if @matrix.all? { |col| col[y] }
        lines_cleared += 1

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
end
