FPS = 60
DAS = 20
SPAWN_DELAY = 12
LOCK_DOWN_DELAY = 30

MINO_SIZE = 30
MATRIX_WIDTH = 10
MATRIX_HEIGHT = 20

PIECES = [
  {
    shape: :i,
    minos: [[nil, nil, 1, nil]] * 4,
    color: [0, 100, 100]
  },
  {
    shape: :j,
    minos: [[nil, 1, 1], [nil, 1, nil], [nil, 1, nil]],
    color: [0, 0, 255]
  },
  {
    shape: :l,
    minos: [[nil, 1, nil], [nil, 1, nil], [nil, 1, 1]],
    color: [255, 165, 0]
  },
  {
    shape: :o,
    minos: [[1, 1], [1, 1]],
    color: [255, 255, 0]
  },
  {
    shape: :s,
    minos: [[nil, 1, nil], [nil, 1, 1], [nil, nil, 1]],
    color: [0, 255, 0]
  },
  {
    shape: :t,
    minos: [[nil, 1, nil], [nil, 1, 1], [nil, 1, nil]],
    color: [148, 0, 211]
  },
  {
    shape: :z,
    minos: [[nil, nil, 1], [nil, 1, 1], [nil, 1, nil]],
    color: [255, 0, 0]
  }
]

KICK_TESTS = [
  [[0, 0], [-1, 0], [-1, 1], [0, -2], [-1, -2]],
  [[0, 0], [1, 0], [1, -1], [0, 2], [1, 2]],
  [[0, 0], [1, 0], [1, 1], [0, -2], [1, -2]],
  [[0, 0], [-1, 0], [-1, -1], [0, 2], [-1, 2]]
]

KICK_TESTS_I = [
  [[0, 0], [-2, 0], [1, 0], [-2, -1], [1, 2]],
  [[0, 0], [-1, 0], [2, 0], [-1, 2], [2, -1]],
  [[0, 0], [2, 0], [-1, 0], [2, 1], [-1, -2]],
  [[0, 0], [1, 0], [-2, 0], [1, -2], [-2, 1]]
]

# Gravity slowly increases as level increases.
# First index nil since levels start at 1
GRAVITY_VALUES = [
  nil,
  0.01667,
  0.021017,
  0.026977,
  0.035256,
  0.04693,
  0.06361,
  0.0879,
  0.1236,
  0.1775,
  0.2598,
  0.388,
  0.59,
  0.92,
  1.46,
  2.36
]

SOFT_DROP_G = 0.5

