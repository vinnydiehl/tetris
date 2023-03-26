# run another enumerator inside this one
class Enumerator::Yielder
  def run enum
    enum.each { |v| self << v }
  end
end

# get a duration tick enumerator which yields 0...duration to an optional block
# (the duration-th tick yields duration-1). can be used to drive a tick-based
# animation or to delay for a specific amount of time
def ecount duration, &blk
  enum = (0...duration).each
  return enum unless blk
  enum.lazy.map &blk
end

# converts its parameter to an easing function in a way similar to DragonRuby's
# built-in ease, but allows output outside of [0,1].
#
# * pass a symbol to use the same method from GTK::Easing
# * pass an array of args to convert and compose them
# * anything else is left as-is and called directly with t
def create_easing_func *definitions
  definitions.flatten!
  defn =\
    if definitions.empty?
      :identity
    elsif definitions.size == 1
      definitions.first
    else
      definitions
    end

  case defn
  when Symbol
    GTK::Easing.method(defn)
  when Array
    procs = defn.map { |a| create_easing_func(a) }
    proc do |t|
      procs.reduce(t) { |memo, f| f[memo] }
    end
  else # assume it is callable
    defn
  end
end

# get a duration tick enumerator which yields 0..1 to the block (the
# duration-th tick yields 1). used to drive ease-based animations.
#
# pass additional args to control easing. see create_easing_func
def eease duration, *definitions, &blk
  curve = create_easing_func *definitions

  Enumerator.new do |yielder|
    if duration == 1
      yielder << blk[1.0]
    else
      last_i = (duration - 1).to_f
      (0...duration).each do |i|
        yielder << blk[curve[i / last_i]]
      end
    end
  end
end

class Numeric
  # linear interpolate from start to finish as this number varies from 0 to 1
  def lerp start, finish
    ((finish - start) * self + start).to_f
  end
end
