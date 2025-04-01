#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SNUMBER=$(( ( RANDOM % 1000 )  + 1 ))
echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 1001)")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users where user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game from users where user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
NUM_OF_GUESSES=0
echo "Guess the secret number between 1 and 1000:"
echo $SNUMBER
GUESS=-1
while [[ $GUESS -ne $SNUMBER ]]
do
  (( NUM_OF_GUESSES++ ))
  read GUESS
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $SNUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else 
    echo "It's lower than that, guess again:"
  fi
done
echo "You guessed it in $NUM_OF_GUESSES tries. The secret number was $SNUMBER. Nice job!"
USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
UPDATE_GAME_COUNT=$($PSQL "update users set games_played=games_played+1 where user_id=$USER_ID")
UPDATE_BEST_GAME=$($PSQL "update users set best_game=least(best_game, $NUM_OF_GUESSES) where user_id=$USER_ID")