# rubocop: disable all
 
##rules to follow: 
  # max 100 lines per class
  # max 5 lines in method
  # max 4 paramters per method

##storing data
  #store the board in nested arrays
    #prob need to associate colours to numbers 
  #store the hints in nested arrays 
    #red peg = 2, white peg = 1, 

## displaying board 
  #display the board with hint on the right side 
  #need to use colorize gem to colour the pins 
  # use basic circle symbol '●' to display pins and hint pegs

#wrap everything in mastermind module for namespacing 

##game class
  #methods to display board
  #methods to play each round
  #methods to determine check the winner 
    #announce the winner and stop the game

##Player class 
  #initialise with @game instance variable to assign game class
    #so it can use the methods from game class like this @game.methods  

##humanplayer class < Player
  #method to choose the colours and pass it to game class to place them in the board 

##computerPlayer class < player
  #methods to choose the colours with ai
    #how am i gonna write the code for this? idk..  
## rubocop: enable all

require 'colorize'


module MasterMind
  
  class Game 
    @@colours = ["red","blue","yellow","green","magenta","white","black","light_cyan"]
    @@circle = "●"
    @@empty_circle = "○"
    @@coloured_symbols = @@colours.map {|element| @@circle.colorize(element.to_sym)} 
    @@hint_symbols = [@@empty_circle,@@circle, @@circle.colorize(:red)]

    attr_reader :board, :hint, :turns

    def initialize()
      puts "welcome to mastermind, please choose the game mode"
      @game_mode = ask_game_mode
      @turns = ask_for_number_of_turns 
      @board = Array.new(@turns) { Array.new(4)}
      @hint = Array.new(@turns)  { Array.new(4)}
    end

    #make your select between game mode
    def ask_game_mode 
      available_modes = [1,2]
      answer = nil
      until available_modes.include?(answer)
        puts "choose game mode, for humanplayer: 1 , for computerplayer: 2"
        answer = gets.chomp.to_i 
      end 
      answer 
    end

    #how many turns the user want? 
    def ask_for_number_of_turns
      turn_range = (12..20).to_a
      answer = nil
      until turn_range.include?(answer)
        puts "choose number of turns, between 12 - 20"
        answer = gets.chomp.to_i 
      end 
      answer
    end

    #draws game board
    def draw_board_and_hints
      ##      {o|o|o|o}  hint: [|o|o|o|o|] 
      #some buffer for better terminal viewing experience
      3.times {puts ""}
      ##combine each row from two arrays as a element of new array
      completed_game_board = turns.times.map {|row|"     { #{get_one_row(row,board,@@coloured_symbols)} }    hint: [ #{get_one_row(row,hint,@@hint_symbols)} ]"}
      ##so, i can add the visual seperaters with code below
      puts completed_game_board.join("\n---------------------------------------\n")     
      3.times {puts ""}

    end

    ##turn the number values from @board and @hint and turn them into array of symbols
    def get_one_row(row_number,board_or_hint, symbol_list)
      row = board_or_hint[row_number].map do |element|
        if element == nil 
          element = @@empty_circle
        else
          element = symbol_list[element]
        end  
      end
      row.join("|")
    end

    ##method to put random numbers on the board 
    def random_num_gen
      board.each do |row|
        row.each_with_index {|element,index| row[index] = Random.rand(0..7)}
      end
    end
  end
end


include MasterMind

new_game = Game.new() 

new_game.random_num_gen

new_game.draw_board_and_hints

# puts new_game.board