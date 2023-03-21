# Gravity slowly increases as level increases.
# First index nil since levels start at 1
GRAVITY_VALUES = [
  nil,
  0.01667,
  0.021017,
  0.026977,
  0.035256,
  0.04693,
  0.06361,
  0.0879,
  0.1236,
  0.1775,
  0.2598,
  0.388,
  0.59,
  0.92,
  1.46,
  2.36
]

SOFT_DROP_G = 0.5

class TetrisGame
  def calculate_gravity(soft_drop_input)
    original = @gravity

    # Soft drop if down input, otherwise use G value based on level
    @gravity = @current_tetromino[:hard_dropped] ? 20 :
      soft_drop_input ? SOFT_DROP_G : GRAVITY_VALUES[[@level, 15].min]

    # If the gravity has changed this frame, need to reset the gravity/age
    # delay to the correct interval
    reset_gravity_delay if @gravity != original
  end

  # Runs every frame that gravity is active (i.e. when `!current_piece_colliding_y?`).
  # This works by setting 2 values when the tetromino is created; the age, which
  # starts at 0, and gravity_delay, which starts at some about (lower gravity = higher
  # delay), and the delay strives to always remain ahead of the age. If the age
  # surpasses the delay, we need to keep dropping the tetromino until we can catch it up.
  #
  def apply_gravity
    while @current_tetromino[:age] > @current_tetromino[:gravity_delay]
      @current_tetromino[:y] -= 1

      # If you move downward, the lockdown delay AND # of extensions are reset
      reset_lock_down_delay(true)

      if current_tetromino_colliding_y?
        break
      end

      # The higher the gravity, the more of a shove we give the delay; at the starting
      # gravity 0.01667, this adds 59.98 frames to the delay, for example, causing a
      # drop rate of roughly 1/sec at 60FPS. At 1G, this will bump the delay by only 1 frame,
      # causing a 60 Hz drop. Essentially, the higher the gravity, the slower the delay
      # catches up to the age, causing the tetromino to drop more cells in that frame.
      @current_tetromino[:gravity_delay] += 1 / @gravity
    end

    @current_tetromino[:age] += 1 if @current_tetromino
  end

  # Resets the gravity delay according to the currently set gravity, or a custom
  # gravity that may be passed in.
  def reset_gravity_delay(gravity=nil)
    @current_tetromino[:gravity_delay] = @current_tetromino[:age] + (1 / (gravity || @gravity))
  end
end
