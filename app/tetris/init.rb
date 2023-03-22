class TetrisGame
  def initialize(args)
    @args = args

    @level = 1
    @score = 0
    @lines_cleared = 0
    @back_to_back_active = false

    # This will indicate whether a T-Spin (and what type,
    # :full or :mini) was scored this turn
    @t_spin = nil

    @gravity = GRAVITY_VALUES[1]

    @matrix = Array.new(MATRIX_WIDTH) { Array.new(MATRIX_HEIGHT, nil) }

    @das_timeout = DAS
    @as_frame_timer = 0

    @bag = []
    @held_tetromino = nil
    @hold_available = true

    @delayed_procs = []

    spawn_tetromino
  end

  def tick
    game_tick
    render
  end
end
