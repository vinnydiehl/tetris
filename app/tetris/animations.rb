SHUTTER_HEIGHT = MINO_SIZE / 2
SHUTTER_COUNT = (DISPLAY_HEIGHT / SHUTTER_HEIGHT).floor
SHUTTER_ANIMATION_FRAMES = (4 / SHUTTER_COUNT).seconds

# Saturation and value for the randomly
# generated game over animation colors
S = 0.8
V = 0.95

class TetrisGame
  # Runs once on game start, called from #game_init
  def init_animations
    # This hash contains all currently running animations. They are looped
    # through, advanced and rendered every tick.
    @animations = {}

    @countdown_state = "Ready"
    @animation_matrix = empty_matrix

    # The game over animation is a "curtain" composed of randomly generated
    # complementary colors. These colors are arranged vertically in a series
    # of 300x15 "shutters". As each one is animated it is added to this array
    # so that it persists for the rest of the animation:
    @closed_shutters = []

    # Start with a random hue
    h = rand
    @shutter_colors = SHUTTER_COUNT.times.map do
      # Use the golden ratio to advance the hue, resulting in an even
      # distribution with no two similar colors adjacent
      h += 0.618033988749895
      h %= 1

      # Convert to RGB:

      h_i = (h * 6).to_i
      f = (h * 6) - h_i
      p = V * (1 - S)
      q = V * (1 - (f * S))
      t = V * (1 - ((1 - f) * S))

      r, g, b =\
        case h_i
        when 0 then [V, t, p]
        when 1 then [q, V, p]
        when 2 then [p, V, t]
        when 3 then [p, q, V]
        when 4 then [t, p, V]
        when 5 then [V, p, q]
        end

      [(r * 256).floor, (g * 256).floor, (b * 256).floor]
    end
  end

  # To begin an animation from the game, all you need to do is run this method
  # once, on the frame that the animation begins. The animation will play out
  # from there and end itself, or you can end it early with `#end_animation`
  #
  # There needs to be a method in this file `#animate_NAME` (replace NAME with
  # the +name+ passed into this method). That method will then run every tick
  # until end_animation(NAME) is called. Its animation state is initialized at
  # nil and saved at @animations[NAME].
  #
  # Will raise a RuntimeError if the animation is already playing.
  #
  # @param name [Symbol] name of the animation
  def begin_animation(name)
    raise "Animation #{name} is already running." if animating? name
    @animations[name] = nil
  end

  # Ends an animation; this animation code runs fairly late in the game loop so
  # if this is called from the game the animation will not play that frame.
  #
  # @param name [Symbol] name of the animation
  def end_animation(name)
    @animations.delete name
  end

  # @param names [Array] name(s) of animations to check
  # @return [Boolean] whether or not any of the animations are currently running
  def animating?(*names)
    names.any? { |name| @animations.keys.include? name }
  end

  def animation_tick
    @animations.each { |name, _| send "animate_#{name}" }
  end

  def animate_countdown
    @animations[:countdown] ||= Enumerator.new do |animator|
      play_sound_effect "events/#{
        %w[3 2 1].include?(@countdown_state) ? 'count' : @countdown_state.downcase
      }"

      attrs = {
        text: @countdown_state,
        x: @args.grid.w / 2,
        y: (@args.grid.h / 2) + 25,
        size_enum: 4,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255
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
      @countdown_state =\
        case @countdown_state
        when "Ready" then "3"
        when   "3"   then "2"
        when   "2"   then "1"
        when   "1"
          # Delay syncs perfectly with the sound effect and fade-in
          delay(20) { @game_started = true }
          set_music "game_intro", "game_loop"
          "Go"
        else
          end_animation :countdown
          nil
        end

      @animations[:countdown] = nil if animating?(:countdown)
    end
  end

  def animate_hard_drop
    @animations[:hard_drop] ||= Enumerator.new do |animator|
      play_sound_effect "tetromino/hard_drop"

      orig_position = @current_tetromino.clone

      # We've already calculated the position it's going to land in; the
      # ghost! We'll just yoink that and get rid of the alpha channel...
      @new_position = @ghost.clone
      @new_position.color.pop

      height_difference = orig_position.y - @new_position.y
      height_difference_px = height_difference * MINO_SIZE

      @score += height_difference * 2

      @max_translation = 0

      animator.run(
        # This falls at a constant speed: travel time is height_difference_px / 60 frames
        eease((height_difference_px / 60).floor, Bezier.ease(0.84, 0.21, 0.92, 0.82)) do |t|
          translation = [t.lerp(0, height_difference_px), height_difference_px].min
          @max_translation = [@max_translation, translation].max

          # Fade out the alpha slightly during the first quarter of its travel,
          # then back in during the last
          orig_position.color[3] = [
            [(4 * translation / height_difference_px),
             (4 - (4 * translation / height_difference_px))].min,
          1].min.lerp(255, GHOST_ALPHA)

          render_tetromino orig_position, y_translate: -translation,
            # Use a darkened version of the tetronimo's color for the border as it falls
            border: orig_position.color.first(3).map { |c| c / 4 }

          render_tetromino_blur orig_position, translation,
            t.lerp(translation, translation * 0.5),
            [(translation/(height_difference_px / 4)), 1].min.lerp(255, GHOST_ALPHA)
        end +
        # Retract the motion blur now that the tetromino has landed
        eease(0.1.seconds, Bezier.ease(0.25, 1.06, 0.72, 0.98)) do |t|
          # Render the tetromino that has landed at the bottom
          render_tetromino orig_position, y_translate: -@max_translation
          render_tetromino_blur orig_position, @max_translation,
                                t.lerp(@max_translation * 0.5, 0), GHOST_ALPHA
        end
      )
    end

    begin
      @animations[:hard_drop].next
    rescue StopIteration
      end_animation :hard_drop

      @current_tetromino = @new_position
      render_tetromino @current_tetromino
    end
  end

  def render_tetromino_blur(orig_position, translation, height, alpha)
    tetromino_height = orig_position.minos.first.size

    orig_position.each_with_coords do |mino, x, y|
      # Only display a blur sprite above the top blocks in the tetromino
      if mino && (y == tetromino_height - 1 ||
                  orig_position.minos[x - orig_position.x][y - orig_position.y + 1].nil?)
        blur_x, blur_y = mino_px_position x, y + 1
        @args.outputs.primitives << {
          path: "sprites/blur/#{orig_position.shape}.png",
          x: blur_x,
          # Stretch vertically as the tetromino translates downward
          y: blur_y - translation,
          w: MINO_SIZE,
          h: height,
          a: alpha
        }
      end
    end
  end

  def animate_line_clear
    @animations[:line_clear] ||= Enumerator.new do |animator|
      colors = @animation_matrix.deep_dup

      # Save the Y-values of the lines that were cleared, then reset this
      @lines_cleared_animating = @lines_cleared_this_frame.clone
      @lines_cleared_this_frame = []

      animator.run(
        # Flash white
        eease(0.25.seconds, Bezier.ease(0.41, 0.79, 0.78, 0.97)) do |t|
          MATRIX_WIDTH.times do |x|
            @lines_cleared_animating.each do |y|
              @animation_matrix[x][y] = colors[x][y]&.map { |value| t.lerp(value, 255) }
            end
          end
        end +
        # Fade out
        eease(0.5.seconds, Bezier.ease(0.58, 0.31, 0.67, 0.72)) do |t|
          MATRIX_WIDTH.times do |x|
            @lines_cleared_animating.each do |y|
              @animation_matrix[x][y] = [255, 255, 255, t.lerp(255, 0)]
            end
          end
        end
      )
    end

    begin
      @animations[:line_clear].next
      render_matrix @animation_matrix
    rescue StopIteration
      @lines_cleared_animating.reverse_each do |y|
        @animation_matrix.each do |col|
          col[y] = nil
        end
      end

      render_matrix @animation_matrix

      end_animation :line_clear
      begin_animation :line_fall
    end
  end

  def animate_line_fall
    @animations[:line_fall] ||= Enumerator.new do |animator|
      delay(10) { play_sound_effect "score/line_fall" }

      animator.run(
        eease(0.5.seconds, Bezier.ease(0.34, 0.06, 0.80, 0.81)) do |t|
          @animation_matrix.each_with_index do |col, x|
            col.each_with_index do |color, y|
              # Get translation from the original position in pixels; this is calculated by
              # multiplying the number of lines that were cleared beneath that line by
              # number of pixels we're at in the animation state, e.g. with a matrix like:
              #
              #     0 0 0 0 - 120px
              #     0 1 0 0 -  90px - n < y: 2
              #     x x x x -  60px
              #     1 1 1 0 -  30px - n < y: 1
              #     x x x x -   0px
              #
              # where x was just cleared, after 1 frame of animation the row at 30px is now
              # at 29 (1 * 1 = 1px translation), and the row at 90px is now at 28; (2 * 1);
              # this allows the gap to smoothly close even if there is a row uncleared
              # between. When we're lerped to 30, the row at 30px is now at 0 (1 * 30),
              # and the row at 90px is now at 30 (2 * 30).
              translation =
                @lines_cleared_animating.select { |n| n < y }.size * (t.lerp(1, MINO_SIZE))

              # This height check renders the next one up (hidden behind the border) so
              # that it slides down. It uses the pixel translation to render the next one
              # in only after it has slid down far enough that it is hidden behind the border
              if color && (y * MINO_SIZE) - translation <= DISPLAY_HEIGHT
                render_mino x, y, *color, y_translate: -translation
              end
            end
          end
        end
      )
    end

    begin
      @animations[:line_fall].next
    rescue StopIteration
      end_animation :line_fall

      # This needs to be rendered here or it gets dropped for a frame due to the
      # rendering order. They can't be switched or it drops a frame on the line clear
      # animation so here you go.
      render_matrix @matrix
    end
  end

  def animate_game_over
    @animations[:game_over] ||= Enumerator.new do |animator|
      @game_over = true
      @args.audio[:music] = nil
      play_sound_effect "events/game_over" if @closed_shutters.empty?

      animator.run(
        eease(SHUTTER_ANIMATION_FRAMES, :identity) do |t|
          height = t.lerp(0, SHUTTER_HEIGHT)
          r, g, b = @shutter_colors.last

          shutter = {
            primitive_marker: :solid,
            x: (@args.grid.w / 2) - (MATRIX_PX_WIDTH / 2),
            y: MATRIX_Y0 + DISPLAY_HEIGHT - height - (SHUTTER_HEIGHT * @closed_shutters.size),
            w: MATRIX_PX_WIDTH,
            h: height,
            r: r,
            g: g,
            b: b
          }

          # t >= 1 means the shutter has fully lowered, transfer it to @closed_shutters
          # to persist it throughout the rest of the animation
          if t >= 1
            @closed_shutters << shutter
            @shutter_colors.pop
          end

          @args.outputs.primitives << shutter
        end
      )
    end

    begin
      render_closed_shutters
      @animations[:game_over].next
    rescue StopIteration
      if @shutter_colors.empty?
        end_animation :game_over
        delay(30) { set_scene :game_over }
      end

      @animations[:game_over] = nil if animating?(:game_over)
    end
  end

  def render_closed_shutters
    @args.outputs.primitives << @closed_shutters
  end
end
