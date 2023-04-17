class String
  # Creates a label primitive with the given options.
  #
  # @param x [Integer] x-coordinate in pixels
  # @param y [Integer] y-coordinate in pixels
  #
  # @option :size [Integer] the size of the text
  # @option :alignment [Symbol] :left, :center, or :right
  # @option :r [Integer] RGBa red value
  # @option :g [Integer] RGBa green value
  # @option :b [Integer] RGBa blue value
  # @option :a [Integer] RGBa alpha value
  def label(x, y, size: 1, alignment: 0, r: 255, g: 255, b: 255, a: 255)
    if alignment.is_a?(Symbol)
      alignment = {left: 0, center: 1, right: 2}[alignment]
    end

    {
      text: self,
      x: x, y: y,
      size_enum: size,
      alignment_enum: alignment,
      r: r, g: g, b: b, a: a
    }
  end
end
