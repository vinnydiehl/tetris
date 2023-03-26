class TetrisGame
  # Runs once on game start, called from #game_init
  def init_animations
    @animation = nil
    @countdown_animating = true
    @countdown_state = "Ready"
  end

  def animation_tick
    animate_countdown if @countdown_animating
  end

  def animate_countdown
    @animation ||= Enumerator.new do |yielder|
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

      yielder.run(
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
      @animation.next
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
        @countdown_animating = false
        nil
      end

      @animation = nil
    end
  end
end
