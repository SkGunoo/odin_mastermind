
require 'colorize'


module MasterMind
  
  class Game 
    @@colours = ["red","blue","yellow","green","magenta","white","black","light_cyan"]
    @@circle = "●"
    @@empty_circle = "○"
    @@coloured_symbols = @@colours.map {|element| @@circle.colorize(element.to_sym)} 
    @@hint_symbols = [@@empty_circle,@@circle, @@circle.colorize(:red)]
    attr_accessor :player
    attr_reader :board, :hint, :turns, :code_to_guess, :game_mode

    def initialize()
      puts "welcome to mastermind, please choose the game mode"
      @game_mode = ask_game_mode
      @turns = ask_for_number_of_turns 
      @board = Array.new(@turns) { Array.new(4)}
      @hint = Array.new(@turns)  { Array.new(4)}
      @code_to_guess = (0..7).to_a.shuffle[0..3]
      @player = human_or_computer_player(@game_mode)
      play_game
      # @code_to_guess = [0,4,5,7]

    end

    private
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
      turn_range = (2..20).to_a
      answer = nil
      until turn_range.include?(answer)
        puts "choose number of turns, between 12 - 20(lower turns are harder)"
        answer = gets.chomp.to_i 
      end 
      answer
    end

    #setting different classes to @player depends on the game mode
    def human_or_computer_player(game_mode)
      return HumanPlayer.new(board) if game_mode == 1
      return ComputerPlayer.new(board, code_to_guess) if game_mode == 2
    end

    ##call this method to play the game depends on the game mode
    def play_game
      if game_mode == 1
        human_player_playing_game
      else
        computer_player_playing_game
      end
    end


    #call this when user is playing the game
    def human_player_playing_game 
      turns.times do |turn|
        player.place_symbols(turn,ask_player_for_codes())
        update_hint_board(turn)
        break if game_won_or_lost?(turn)
        draw_board_and_hints
      end
    end

    #call this when computer is playing game
    def computer_player_playing_game
      turns.times do |turn|
        player.place_symbols(turn,player.computer_passes_the_codes(turn))
        update_hint_board(turn)
        break if game_won_or_lost?(turn)
        draw_board_and_hints
      end
    end

    #determines win or lose based on codes on the board and turn value
    def game_won_or_lost?(turn)
      if board[turn] == code_to_guess
        game_won  
      elsif turns - 1 == turn
        game_lost
      end
    end

    #print out different win messages depends on the game_mode(human or computer player)
    #also ask user about playing another round
    def game_won
      draw_board_and_hints
      if game_mode == 1
        puts "you won the game!!!!"
      else
        guessed = " guessed "
        puts "computer".colorize(:yellow) +  "\e[9m#{guessed}\e[0m"  + "cheated".colorize(:red) + " successfully"
      end

      if try_again?
        restart_game
      else
        true
      end
    end

    #show the answer when user is lost 
    def game_lost
      puts "sorry, you lost"
      print "the answer was:  " 
      show_current_codes(code_to_guess) 
      puts ""
      if try_again?
        restart_game
      else
        true
      end
    end

    #ask user about playing one more round
    def try_again?
      answer = loop do
        puts "do you want to play again? type 'y' for yes 'n' for no"
        answer = gets.downcase.chomp
        break answer if ['y','n'].include?(answer)
      end
      answer == 'y' ? true : false
    end

    #call initialize again to reset all the class states to start fresh
    def restart_game
      initialize
      play_game
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
      completed_game_board = turns.times.map {|row|" turn: #{(row + 1).to_s.rjust(2,'0').colorize(:yellow)}    { #{get_one_row(row,board,@@coloured_symbols)} }    hint: [ #{get_one_row(row,hint,@@hint_symbols)} ]"}
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
    
    attr_accessor :robot_guess, :robot_cheat_sheet
    attr_reader :code_to_guess,:game_board
    def initialize(board,answer)
      @game_board = board 
      @code_to_guess = answer  
      @robot_guess = Array.new(4,nil)
      #adds hash of useful information so computer can cheat 
      @robot_cheat_sheet = (0..7).to_a.each_with_object([]){|num,array| array[num] = {"number" => num,"part of answer?"=>false,"know the position?"=> false ,"what position?"=> nil} }
    end

    def ask_user_to_proceed_to_next_turn
      puts "let computer to take its turn? (press enter)"
     
      gets 
      
    end


    def computer_passes_the_codes(turn)
      ask_user_to_proceed_to_next_turn
      if turn < 2
        codes_for_first_two_turns(turn)
         puts "robot guess : #{robot_guess}"
        update_cheatsheet(@robot_guess)
        return @robot_guess
      else
        update_robot_guess_with_codes_that_robot_know_position
        update_robot_guess_with_codes_that_robot_dont_know_position
        update_cheatsheet(@robot_guess)

        return @robot_guess
      end
    end

    def codes_for_first_two_turns(turn)
      @robot_guess = [0,1,2,3] if turn == 0
      @robot_guess =[4,5,6,7] if turn == 1
    end

    def update_robot_guess_with_codes_that_robot_know_position
      #reset array for new answer
      @robot_guess =  Array.new(4,nil)
      robot_cheat_sheet.each_with_index do |hash, index|
        if hash["part of answer?"] == true && hash["know the position?"] == true
          #index is equal to a code to guess because array indices are equal to the numbers to guess
          @robot_guess[hash["what position?"]] = index
        end
      end
    end

    def update_robot_guess_with_codes_that_robot_dont_know_position
      robot_guess_indices_of_nils = Array.new
      @robot_guess.each_with_index { |code, index| robot_guess_indices_of_nils.push(index) if code == nil}
      #get the codes that we dont know their positions
      codes_that_computer_dont_know_its_position = robot_cheat_sheet.filter_map{|hash| hash["number"] if hash["part of answer?"] == true && hash["know the position?"] == false}
      robot_guess_indices_of_nils.shuffle.each_with_index {|index, iteration_index| robot_guess[index] = codes_that_computer_dont_know_its_position[iteration_index]}
    end


    def update_cheatsheet(robot_guess_codes)
      robot_guess_codes.each_with_index do |code, index|
        if code_to_guess.include?(code)
          robot_cheat_sheet[code]["part of answer?"] = true
          #if one of the guess is right number AND at the right position update the hash
          if code == code_to_guess[index]
            robot_cheat_sheet[code]["know the position?"] = true
            robot_cheat_sheet[code]["what position?"] = index
          end
        end
      end
    end
  end
end


include MasterMind

Game.new()

# 




# rubocop: disable all
 

#these are my rules before i started the project
##rules to follow: 
  # max 100 lines per class : couldnt do this, need to plan things wayy better
  # max 5 lines in method :somewhat followed the rule
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
# rubocop: enable all
