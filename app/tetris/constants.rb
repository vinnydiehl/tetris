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

# Block size of the matrix
MATRIX_WIDTH = 10
MATRIX_HEIGHT = 20

# Opacity of the ghost (0-255)
GHOST_ALPHA = 80

# Opacity of the held piece before it is made available (0-255)
UNAVAILABLE_HOLD_ALPHA = 50
