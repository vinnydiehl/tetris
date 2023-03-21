%w[constants init render delay gravity
   lock_down rotation scoring tetronimo].each { |f| require "app/tetris/#{f}.rb" }

%w[game].each { |f| require "app/tetris/scenes/#{f}.rb" }

def tick(args)
  args.state.game ||= TetrisGame.new(args)
  args.state.game.tick
end

$gtk.reset
