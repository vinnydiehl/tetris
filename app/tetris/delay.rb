# frozen_string_literal: true

class TetrisGame
  # Delay the execution of +block+ by +frames+. The code in the block will
  # be placed in a buffer with a timeout, and all of the block will be
  # executed on the frame when that timeout reaches zero.
  #
  # @param frames [Integer] number of frames to delay
  def delay(frames, &block)
    @delayed_procs << [frames, block]
  end

  # This is run every frame to advance the timers on each #delay
  # proc, run any that have timed out, and prune old ones.
  def handle_delayed_procs
    @delayed_procs.select! { |frames, _| frames >= 0 }

    @delayed_procs.map! do |frames, func|
      # We decrement after the call attempt, so it times out at 1
      func.call if frames == 1
      [frames - 1, func]
    end
  end
end
