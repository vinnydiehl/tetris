class Array
  # Span an array of strings into several labels with even spacing.
  #
  # @param x [Integer] x-coordinate in pixels of the top label
  # @param y [Integer] y-coordinate in pixels
  # @param spacing [Integer] the space in pixels between the labels
  #
  # @option :size [Integer] the size of the text
  # @option :alignment [Symbol] :left, :center, or :right
  # @option :r [Integer] RGBa red value
  # @option :g [Integer] RGBa green value
  # @option :b [Integer] RGBa blue value
  # @option :a [Integer] RGBa alpha value
  def span_vertically(x, y, spacing, size: 1, alignment: 0, r: 255, g: 255, b: 255, a: 255)
    # String#label would do this anyway, but it's more efficient to do it here
    if alignment.is_a?(Symbol)
      alignment = {left: 0, center: 1, right: 2}[alignment]
    end

    each_with_index.map do |str, i|
      next if str.nil? || str.empty?

      str.label x, y - (spacing * i),
                size: size, alignment: alignment,
                r: r, g: g, b: b, a: a
    end.compact
  end
end
