#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SNUMBER=$(( ( RANDOM % 1000 )  + 1 ))
echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games GROUP BY user_id HAVING user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(n_guesses) FROM games GROUP BY user_id HAVING user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
NUM_OF_GUESSES=0
echo "Guess the secret number between 1 and 1000:"
GUESS=$SNUMBER-1
while [[ $GUESS -eq $SNUMBER ]]
do
  (( NUM_OF_GUESSES++ ))
  read GUESS
  if ![[ $GUESS =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $SNUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else 
    echo "It's higher than that, guess again:"
  fi
done
echo ""