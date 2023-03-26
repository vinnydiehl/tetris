class TetrisGame
  # Runs once on game start, called from #game_init
  def init_animations
    @animation = nil
    @ready_go_animating = true
    @ready_go_state = nil
  end

  def animation_tick
    animate_ready_go if @ready_go_animating
  end

  def animate_ready_go
    unless @ready_go_state
      play_sound_effect "events/ready"
    end

    @ready_go_state ||= "Ready"

    @animation ||= Enumerator.new do |yielder|
      attrs = {
        text: @ready_go_state,
        x: @args.grid.w / 2,
        y: @args.grid.h / 2,
        size_enum: 4,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
      }

      yielder.run(
        eease(1.seconds, Bezier.ease(0.67, 0.62, 0.55, 1.00)) do |t|
          @args.outputs.labels << { a: t.lerp(0, 255), **attrs }
        end +
        eease(0.5.seconds, Bezier.ease(0.15, 0.94, 0.71, 0.94)) do |t|
          @args.outputs.labels << { a: t.lerp(255, 0), **attrs }
        end
      )
    end

    begin
      @animation.next
    rescue StopIteration
      if @ready_go_state == "Ready"
        # Delay syncs perfectly with the sound effect and fade-in
        delay 20 { @game_started = true }
        play_sound_effect "events/go"
        @ready_go_state = "Go"
      else
        @ready_go_state = nil
        @ready_go_animating = false
      end

      @animation = nil
    end
  end
end
