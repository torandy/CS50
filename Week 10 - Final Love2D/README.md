# CS50x Final Project: Simon
## Video Demo:  [CS50x Final Project: Simon](https://youtu.be/tey5yIBCY4Y)
### Author: Randy To  
### Location: Ontario, Canada <br /> <br>
## Description:
####
This is a memory game where the object of the game is to correctly repeat the sequence played by the computer.

1) A user is asked the # of rounds they wish to play.
2) Computer then generates a pattern based on the # of rounds inputted and then begins playing the sequence starting at 1.
3) User is then asked to play back the same sequence.
4) The game ends when either the user misplayed the sequence or when the user succesfully plays the sequence up to # of rounds inputted.
5) There is an option to replay the game at the end of the game.

## Code:
**confl.lua**
- this is for setting up some global settings
- t.console opens a console screen that really helped with debugging

**main.lua**
- this is a mandatory file for love2d games
- imports and runs all the files required to run the game

**title.lua**
- this file drives the beginning title screen
- provides an overview and keys used in the gameplay
- logic to bound the player between 1-9 rounds

**gameboard.lua**
- this is the heart of the game logic
- uses the classic library to create create an instance of a square object
- uses many variables to help with determining current state of the game
- gameboard:update - controls game state and updates rounds
- gameboard:draw - handles all display objects within the gameboard
- helper functions - multiple functions are built to help determine when clicking, lit/unlit box, validation etc.  See comments in code

**sound.lua**
- added sound for when a button is lit

**square.lua**
- this is a class for creating a square, some variables were declared for future feature but not used

**/libs/classic.lua**
- this is a library to help create a class of square

## Challenges:
- initial designs was to build additional levels such as having sounds and clicking buttons associated to the sound and additing additional buttons as the level progresses, but due to time constraints, could not
- timer was a big challenge to overcome, in the update function, the timer using dt doesn't work properly within loops even trying using do while loops.  I experimented with several timer libs with no success. This resulted in an overhaul of the logic on the playing sequence that required nested if statements and additional variables to help with managing the state.
- a bit of time was spent trying to learn the love2d framework and how to structure it outside of just one main.lua file
