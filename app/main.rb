SCENES = %w[main_menu game]

%w[constants init delay gravity lock_down
   rotation scoring tetronimo].each { |f| require "app/tetris/#{f}.rb" }

%w[scenes render].each { |dir| SCENES.each { |f| require "app/tetris/#{dir}/#{f}.rb" } }

require "app/tetris/render/shared.rb"

def tick(args)
  args.state.game ||= TetrisGame.new(args)
  args.state.game.tick
end
