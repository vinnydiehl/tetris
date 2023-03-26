# Adapted from:
# https://github.com/gre/bezier-easing
# BezierEasing - use bezier curve for transition easing function
# by Gaëtan Renaudeau 2014 - 2015 – MIT License

module Bezier
  # These values are established by empiricism with tests (tradeoff: performance VS precision)
  NEWTON_ITERATIONS = 4
  NEWTON_MIN_SLOPE = 0.001
  SUBDIVISION_PRECISION = 0.0000001
  SUBDIVISION_MAX_ITERATIONS = 10
  K_SPLINE_TABLE_SIZE = 11
  K_SAMPLE_STEP_SIZE = 1.0 / (K_SPLINE_TABLE_SIZE - 1.0)

  def self.ease x1, y1, x2, y2
    x1 = x1.cap_min_max(0, 1)
    x2 = x2.cap_min_max(0, 1)

    if x1 == y1 && x2 == y2
      return proc { |t| t }
    end

    # precompute samples table
    sample_values = Array.new(K_SPLINE_TABLE_SIZE) do |i|
      calc_bezier(i * K_SAMPLE_STEP_SIZE, x1, x2)
    end

    get_t_for_x = lambda do |x|
      interval_start = 0.0
      current_sample = 1
      last_sample = K_SPLINE_TABLE_SIZE - 1

      while current_sample != last_sample && sample_values[current_sample] <= x
        interval_start += K_SAMPLE_STEP_SIZE
        current_sample += 1
      end
      current_sample -= 1

      # Interpolate to provide an initial guess for t
      dist = (x - sample_values[current_sample]) / (sample_values[current_sample + 1] - sample_values[current_sample]).to_f
      guess_for_t = interval_start + dist * K_SAMPLE_STEP_SIZE

      initial_slope = get_slope(guess_for_t, x1, x2)
      if initial_slope >= NEWTON_MIN_SLOPE
        newton_raphson_iterate(x, guess_for_t, x1, x2)
      elsif initial_slope == 0.0
        guess_for_t
      else
        binary_subdivide(x, interval_start, interval_start + K_SAMPLE_STEP_SIZE, x1, x2)
      end
    end

    proc do |x|
      # because floats are imprecise, we should guarantee the extremes are right.
      if x == 0 || x == 1
        x
      else
        calc_bezier(get_t_for_x[x], y1, y2)
      end
    end
  end

  private

  def self.ba a1, a2
    1.0 - 3.0 * a2 + 3.0 * a1
  end

  def self.bb a1, a2
    3.0 * a2 - 6.0 * a1
  end

  def self.bc a1
    3.0 * a1
  end

  # returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
  def self.calc_bezier t, a1, a2
    ((ba(a1, a2) * t + bb(a1, a2)) * t + bc(a1)) * t
  end

  # returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.
  def self.get_slope t, a1, a2
    3.0 * ba(a1, a2) * t * t + 2.0 * bb(a1, a2) * t + bc(a1)
  end

  def self.binary_subdivide x, a, b, x1, x2
    current_x = 0
    current_t = 0
    i = 0
    loop do
      current_t = a + (b - a) / 2.0
      current_x = calc_bezier(current_t, x1, x2) - x
      if current_x > 0.0
        b = current_t
      else
        a = current_t
      end
      break if current_x.abs <= SUBDIVISION_PRECISION
      i += 1
      break if i >= SUBDIVISION_MAX_ITERATIONS
    end
    current_t
  end

  def self.newton_raphson_iterate x, a_guess_t, x1, x2
    NEWTON_ITERATIONS.times do |i|
      current_slope = get_slope(a_guess_t, x1, x2)
      if current_slope == 0.0
        return a_guess_t
      end
      current_x = calc_bezier(a_guess_t, x1, x2) - x
      a_guess_t -= current_x / current_slope
    end
    a_guess_t
  end
end
