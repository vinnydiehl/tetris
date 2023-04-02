# frozen_string_literal: true

class TetrisGame
  def inputs_any?(**inputs)
    # Support for either single or array input for the value
    inputs.each { |k, v| inputs[k] = [v].flatten }

    inputs[:kb]&.any? { |input| @kb_inputs.send input } ||
      inputs[:c1]&.any? { |input| @c1_inputs.send input }
  end

  # Inputs that navigate backwards through the UI menus.
  def inputs_back?
    inputs_any? kb: %i[escape space], c1: %i[start a b]
  end

  # For detecting button combos. Pass them in as separate params:
  #
  #   c1_inputs_all?(:a, :b) # A + B
  #
  # You can also pass in an array as a param to check for any of those:
  #
  #   c1_inputs_all?(:a, :b, %i[l1 l2 r1 r2]) # A + B + any trigger or shoulder button
  def c1_inputs_all?(*inputs)
    inputs.map! { |v| [v].flatten }

    inputs.all? do |input_group|
      input_group.any? { |input| @c1_inputs.send(input) || @c1_inputs_held.send(input) }
    end
  end

  # Very forgiving; accepts any combination of shoulder and trigger buttons, as long as
  # one button from either side is pressed at the same time.
  def l_r_held?
    c1_inputs_all? %i[l1 l2], %i[r1 r2]
  end
end
