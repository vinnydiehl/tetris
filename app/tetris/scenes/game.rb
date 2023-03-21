class TetrisGame
  def game_tick
    handle_delayed_procs
    handle_input

    if @current_tetromino
      apply_gravity unless current_tetromino_colliding_y?

      # Setting this starts the lock down, which can no longer
      # be stopped even if you shift off the stack
      @current_tetromino[:lock_down] = true if current_tetromino_colliding_y? && !locking_down?

      lock_down if locking_down?
    end

    clear_lines
  end

  def handle_input
    if @args.inputs.left && !@args.inputs.right
      if @current_tetromino && !current_tetromino_colliding_x?(:left) &&
         (@das_timeout == DAS || (@das_timeout < 0 && @as_frame_timer == 0))
        @current_tetromino[:x] -= 1

        if locking_down?
          reset_lock_down_delay
          reset_gravity_delay
        end
      end

      @das_timeout -= 1

      if @das_timeout < 0
        @as_frame_timer = (@as_frame_timer - 1) % 3
      end
    elsif @args.inputs.right && !@args.inputs.left
      if @current_tetromino && !current_tetromino_colliding_x?(:right) &&
         (@das_timeout == DAS || (@das_timeout < 0 && @as_frame_timer == 0))
        @current_tetromino[:x] += 1

        if locking_down?
          reset_lock_down_delay
          reset_gravity_delay
        end
      end

      @das_timeout -= 1

      if @das_timeout < 0
        @as_frame_timer = (@as_frame_timer - 1) % 3
      end
    else
      @das_timeout = DAS
      @as_frame_timer = 0
    end

    if @current_tetromino
      kb_inputs = @args.inputs.keyboard.key_down
      gp_inputs = @args.inputs.controller_one.key_down

      if kb_inputs.w || kb_inputs.up ||
         gp_inputs.directional_up || gp_inputs.a
        @current_tetromino[:hard_dropped] = true
      end

      calculate_gravity(@args.inputs.down)

      if kb_inputs.space || kb_inputs.e || gp_inputs.r1
        rotate_current_tetromino(:cw)
      end

      if kb_inputs.q || gp_inputs.l1
        rotate_current_tetromino(:ccw)
      end
    end
  end
end