class Object
  def deep_dup
    case self
    when Hash
      transform_values &:deep_dup
    when Array
      map &:deep_dup
    else
      dup
    end
  end
end
