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