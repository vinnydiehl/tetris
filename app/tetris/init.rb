class TetrisGame
  def initialize(args)
    @args = args

    @level = 1
    @score = 0
    @gameover = false

    @gravity = GRAVITY_VALUES[1]

    @matrix = Array.new(MATRIX_WIDTH) { Array.new(MATRIX_HEIGHT, nil) }

    @das_timeout = DAS
    @as_frame_timer = 0

    @bag = []

    @delayed_procs = []

    spawn_tetromino
  end

  def tick
    game_tick
    render
  end
end
