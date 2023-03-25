class TetrisGame
  # Sets the background music. In cases where there is an intro or fade-in,
  # use 2 arguments; the first one will play once, then transition immediately
  # into the second one, which will loop indefinitely.
  def set_music(*files)
    @args.audio[:music] = { input: "sounds/music/#{files.first}.ogg" }

    if files.size == 1
      @args.audio[:music][:looping] = true
    else
      @music_buffer = {
        input: "sounds/music/#{files[1]}.ogg",
        looping: true
      }
    end
  end

  # Handles volume setting and the looping behavior described for #set_music
  def music_tick
    @args.audio[:music] ||= @music_buffer
    @args.audio[:music][:gain] = @volume
  end

  def set_volume(percent)
    @volume = percent / 100
    @args.audio[:music][:gain] = @volume
  end
end
