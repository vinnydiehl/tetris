class TetrisGame
  # Runs once on game start, called from #game_init
  def init_animations
    # This hash contains all currently running animations. They are looped
    # through, advanced and rendered every tick.
    @animations = {}

    @countdown_state = "Ready"
  end

  # To begin an animation from the game, all you need to do is run this method
  # once, on the frame that the animation begins. The animation will play out
  # from there and end itself, or you can end it early with `#end_animation`.
  #
  # There needs to be a method in this file `#animate_NAME` (replace NAME) with
  # the +name+ passed into this method. That method will then run every tick
  # until end_animation(NAME) is called. Its animation state is initialized at
  # nil and saved at @animations[NAME].
  #
  # @param name [Symbol] name of the animation
  def begin_animation(name)
    @animations[name] = nil
  end

  # Ends an animation; this animation code runs fairly late in the game loop so
  # if this is called from the game the animation will not play that frame.
  #
  # @param name [Symbol] name of the animation
  def end_animation(name)
    @animations.delete name
  end

  # @param name [Symbol] name of the animation
  # @return [Boolean] whether or not the animation is currently running
  def animating?(name)
    @animations.keys.include? name
  end

  def animation_tick
    @animations.each { |name, _| send "animate_#{name}" }
  end

  def animate_countdown
    @animations[:countdown] ||= Enumerator.new do |animator|
      play_sound_effect "events/#{
        %w[3 2 1].include?(@countdown_state) ? "count" : @countdown_state.downcase
      }"

      attrs = {
        text: @countdown_state,
        x: @args.grid.w / 2,
        y: @args.grid.h / 2 + 25,
        size_enum: 4,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
      }

      animator.run(
        # Fade in
        eease(1.seconds, Bezier.ease(0.67, 0.62, 0.55, 1.00)) do |t|
          @args.outputs.labels << { a: t.lerp(0, 255), **attrs }
        end +
        # Fade out
        eease(0.5.seconds, Bezier.ease(0.15, 0.94, 0.71, 0.94)) do |t|
          @args.outputs.labels << { a: t.lerp(255, 0), **attrs }
        end
      )
    end

    begin
      @animations[:countdown].next
    rescue StopIteration
      @countdown_state = case @countdown_state
      when "Ready" then "3"
      when   "3"   then "2"
      when   "2"   then "1"
      when   "1"
        # Delay syncs perfectly with the sound effect and fade-in
        delay 20 { @game_started = true }
        "Go"
      else
        end_animation :countdown
        nil
      end

      @animations[:countdown] = nil if animating?(:countdown)
    end
  end
end
