SCENES = %w[main_menu pause controls game game_over]

%w[constants init inputs music delay gravity
   lock_down rotation scoring tetronimo].each { |f| require "app/tetris/#{f}.rb" }

require "app/tetris/render/shared.rb"

%w[scenes render].each { |dir| SCENES.each { |f| require "app/tetris/#{dir}/#{f}.rb" } }

def tick(args)
  args.state.game ||= TetrisGame.new(args)
  args.state.game.tick
end

