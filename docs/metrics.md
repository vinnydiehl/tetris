# Metrics

This app contains an implementation of the metrics from
[BizhawkMetrics](https://github.com/TetrisMetrics/BizhawkMetrics).

### Per-Frame Metrics

These metrics are run near the end of every frame, after tetromino drops and
scoring have been handled.

 * **Accomodation** - How many of the 7 tetromino shapes have a spot where they can
                      land without creating a hole or a ledge?
 * **Slope** - The angle made by the tops of each column relative to the ground. This
               is always positive, regardless of which direction
 * **Bumpiness** - How often and severely the column heights change
 * **Min/Max Height** - Height of the lowest and highest columns, respectively

### Per-Drop Metrics

These metrics are a little more complicated. This flow runs every time a
tetromino locks down:

![Drought flowchart](https://raw.githubusercontent.com/vinnydiehl/tetris/main/docs/images/drought_flowchart.png)

The resulting values can be described as follows:

 * **Drought** - The number of **non-I** pieces it's been since you've been Tetris ready
   * Pauses when the well gets covered
   * Resumes when Tetris ready again, even if it's a dirty Tetris and the original
     well was not uncovered
 * **Pause** - The number of pieces it's been since you've paused a drought
 * **Surplus** - When you last became Tetris ready, the amount of blocks that would
                 remain if you were to score the Tetris immediately
 * **Readiness** - The number of tetrominoes it took to become Tetris ready from the
                   start of the game, or from the last Tetris scored

These metrics are greyed out while they are not active.

### Other

 * **Presses** - The number of buttons pressed during the fall of a single tetromino

## Averages

On the pause/game over menus, you will see your average metrics from the current game.

The averages for the **per-frame metrics** (as well as **presses**) are calculated
per-drop; that is, the metrics of the current frame are added to a total every time
a tetromino is locked down. The average is this total divided by the number of
tetrominoes that have been dropped.

The averages for the **per-drop metrics** are calculated as follows:

 * **Drought**: Average drought score per drought
 * **Pause**: Average pause score per pause
 * **Surplus**: Average surplus score per Tetris ready
 * **Readiness**: Average readiness score per Tetris ready
