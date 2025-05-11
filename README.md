# Mastermind Game
My version of the [Mastermind board](https://en.wikipedia.org/wiki/Mastermind_(board_game)) game made in Ruby.

## Description
The player plays the game in the command line. The player attempts to guess a pattern of colours. 
After each guess, feedback is provided in the form of red and white colour codes. 
A red code means one of the codes is correctly guessed and it's in the correct place.
A white code means one of the codes is correctly guessed but it's not in the same place.

## Features 
- Human player guessing the code
- Computer player guessing the code (computer cheats)
- You can customise the number of turns (higher turns make the game easier)
- Used Colorize gem to properly visualise the coloured codes

## Requirements 
- Ruby
- Colorize gem

## Game rules 
- The code consists of 4 colours
- Solution code doesn't have duplicated colours (all 4 codes are different colours)
