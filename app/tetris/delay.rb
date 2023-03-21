class TetrisGame
  def delay(frames, &block)
    @delayed_procs << [frames, block]
  end

  def handle_delayed_procs
    # Prune any procs that have already timed out and executed
    @delayed_procs.select! { |frames, _| frames >= 0 }

    # Go through each proc and decrease the timeout, executing if
    # it has reached 0
    @delayed_procs.map! do |frames, func|
      func.call if frames == 0
      [frames - 1, func]
    end
  end
end
