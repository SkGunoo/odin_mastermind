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

    attr_reader :board, :hint, :turns, :player, :code_to_guess

    def initialize()
      puts "welcome to mastermind, please choose the game mode"
      @game_mode = ask_game_mode
      @turns = ask_for_number_of_turns 
      @board = Array.new(@turns) { Array.new(4)}
      @hint = Array.new(@turns)  { Array.new(4)}
      @player = human_or_computer_player(@game_mode)
      @code_to_guess = (0..7).to_a.shuffle[0..3]
      # @code_to_guess = [0,4,5,7]

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

    #setting different classes to @player depends on the game mode
    def human_or_computer_player(game_mode)
      return HumanPlayer.new(board) if game_mode == 1
      return ComputerPlayer.new(board) if game_mode == 2
    end

    ##call this method to play the game
    def play_game
      turns.times do |turn|
        player.place_symbols(turn,ask_player_for_codes())
        update_hint_board(turn)
        draw_board_and_hints
      end
    end
     
    #update hint board with coresponding pins
    def update_hint_board(turn)
      hints = check_for_hints(turn)
      update_hint(hints,turn)
    end

    #checks hint based on current board
    def check_for_hints(turn) 
     red_pins = []
     board[turn].each_with_index {|number, index| red_pins.push(number) if number == code_to_guess[index] }
     rejected = board[turn].reject {| number | red_pins.include?(number)}
     white_pin = []
     rejected.uniq.each {|number| white_pin.push(number) if code_to_guess.include?(number)}
     return [red_pins.size, white_pin.size]
    end

    #1 unshift hint pins to hint[turn] array.
    #2 this will make hint[turn] array bigger than 4
    #3 shave off array elements after 4th one by using [0..3]
    def update_hint(hints,turn)
      #need to put white pins first
      hints[1].times {|number| hint[turn].unshift(1)}
      hints[0].times {|number| hint[turn].unshift(2)}
      hint[turn] = hint[turn][0..3]
    end

    #get 4 codes from user
    def ask_player_for_codes      
      codes_completed = false
      codes = Array.new
      loop do
        # codes  = 4.times.map { |code| code = ask_for_a_code}
        4.times {|number| codes.push(ask_for_a_code(codes))}
        codes_completed = are_you_sure_about_your_codes_choices?(codes)
        codes.clear if codes_completed == false
        break codes if codes_completed == true
      end
    end


    #ask user to choose a single code. 
    def ask_for_a_code(codes)
      #array of name of colours and symbols with coresponding number for code
      colours_and_symbols = Array.new(@@colours.size) { |number| "Type" + " #{number + 1} ".colorize(@@colours[number].to_sym) + "for #{@@colours[number]}(#{@@coloured_symbols[number]})" }
      # colours_and_symbols = Array.new(@@colours.size) { |number| "#{@@colours[number]}(#{@@coloured_symbols[number]}): type #{number + 1}" }

      
      answer =loop do
        puts "--------------------------------"
        draw_board_and_hints
        puts colours_and_symbols.join("\n-\n") 
        ###delete this for answer preview
        # puts show_current_codes(code_to_guess)
        print "\n Code number #{(codes.size + 1)})".colorize(:yellow) + " \n Type number between " + "1 ~ 8".colorize(:red) + " then press enter | my current code input:"
        puts show_current_codes(codes)
        print " My code: "
        answer = gets.chomp.to_i
        break answer - 1 if (0..8).to_a.include?(answer) 
      end

    end

    #show the codes the user selected so far
    def show_current_codes(inputs)
      codes = inputs.map do |element| 
        if element == nil
          element = @@empty_circle
        else
          element = @@coloured_symbols[element]
        end  
      end
      # print " | current inputs : "
      print "{#{codes.join("|")}}"
    end

    #asking your if they made right choice for the row of codes
    def are_you_sure_about_your_codes_choices?(codes)
      answer = loop do 
        show_current_codes(codes)
        puts " Are you sure about your inputs? type: 'y' for yes, 'n' for no "
        answer =gets.chomp 
        break answer if ['y','n'].include?(answer)
      end
      answer == 'y'?  true :   false
    end



    #draws game board
    def draw_board_and_hints
      ##      {o|o|o|o}  hint: [|o|o|o|o|] 
      #some buffer for better terminal viewing experience
      2.times {puts ""}
      ##combine each row from two arrays as a element of new array
      completed_game_board = turns.times.map {|row|"     { #{get_one_row(row,board,@@coloured_symbols)} }    hint: [ #{get_one_row(row,hint,@@hint_symbols)} ]"}
      ##so, i can add the visual seperaters with code below
      puts completed_game_board.reverse.join("\n---------------------------------------\n")     
      2.times {puts ""}

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

  class Player 

    attr_reader :game_board

    def initialize(board)
      @game_board = board 
    end

    def place_symbols(turn, arr)
      game_board[turn] = arr  
    end

  end

  class HumanPlayer < Player

  end

  class ComputerPlayer <Player
    
  end


end


include MasterMind

new_game = Game.new() 

# new_game.random_num_gen

# new_game.draw_board_and_hints

# new_game.test
# 
new_game.play_game



# puts new_game.board