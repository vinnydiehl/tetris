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
    if @args.audio[:music]
      @args.audio[:music][:gain] = @music_enabled ? @volume : 0

      # Hack to get the intro to transition into the looping part smoothly. This was
      # originally set as simply:
      #
      #   @args.audio[:music] ||= @music_buffer
      #
      # at the very beginning of this method, but it was causing a 1 frame delay which
      # was quite noticeable. This switches the music over same-frame.
      if !@args.audio[:music][:looping] &&
         @args.audio[:music][:playtime].round(2) >= @args.audio[:music][:length].round(2)
        @args.audio[:music] = @music_buffer
      end
    end
  end

  def set_volume(percent)
    @volume = percent / 100
    @args.audio[:music][:gain] = @volume if @args.audio[:music]
  end

  def play_sound_effect(file)
    @args.outputs.sounds << "sounds/effects/#{file}.wav"
  end
end
