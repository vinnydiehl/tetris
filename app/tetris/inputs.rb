class TetrisGame
  def inputs_any?(**inputs)
    # Support for either single or array input for the value
    inputs.each { |k, v| inputs[k] = [v].flatten }

    inputs[:kb]&.any? { |input| @kb_inputs.send input } ||
      inputs[:c1]&.any? { |input| @c1_inputs.send input }
  end

  def inputs_back?
    inputs_any? kb: %i[escape space], c1: %i[start a b]
  end
end
