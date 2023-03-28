FPS = 60

# DAS - Delayed Auto-Shift
# This is the # of frames of delay when holding left/right before
# the piece begins to slide more quickly
DAS = 20

# Frames of delay before the next piece spawns after a lock down
SPAWN_DELAY = 12

# Delay before a piece locks down after bottoming out
LOCK_DOWN_DELAY = 30

# Max # of movements that can be made after lock down has initiated
# before the piece immediately locks down. Moving down a level
# resets this
MAX_LOCK_DOWN_ADJUSTMENTS = 15

# Size in pixels of each mino. This sets the scale for the entire matrix
# display and its border.
MINO_SIZE = 30
QUEUE_MINO_SIZE = 28

# How high above the matrix you can see
PEEK_HEIGHT = 15

# Block size of the matrix
MATRIX_WIDTH = 10
MATRIX_HEIGHT = 20
MATRIX_PX_WIDTH = MINO_SIZE * MATRIX_WIDTH
MATRIX_PX_HEIGHT = MINO_SIZE * MATRIX_HEIGHT
DISPLAY_HEIGHT = MATRIX_PX_HEIGHT + PEEK_HEIGHT
MATRIX_Y0 = (720 - MATRIX_PX_HEIGHT) / 2 - (PEEK_HEIGHT / 2)
MATRIX_X0 = (1280 - MATRIX_PX_WIDTH) / 2

# Color of the grid lines behind the matrix
GRID_COLOR = [10, 10, 10]

# Opacity of the ghost (0-255)
GHOST_ALPHA = 80

# Opacity of the held piece before it is made available (0-255)
UNAVAILABLE_HOLD_ALPHA = 50
