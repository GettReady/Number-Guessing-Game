#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"
VALUE=$(($RANDOM % 1000))

echo "Enter your username:"
read USERNAME
USERNAME_RESULT=$($PSQL "select games_played, best_game from users where name='$USERNAME'")
echo $USERNAME_RESULT
if [[ -z $USERNAME_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "insert into users(name, games_played) values('$USERNAME', 0)")  
else
  read GAMES_PLAYED BAR BEST_GAME <<< $USERNAME_RESULT
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."  
fi

NUMBER_OF_GUESSES=0
echo "Guess the secret number between 1 and 1000:"
while [[ $GUESS != $VALUE ]]
do  
  read GUESS  
  ((++NUMBER_OF_GUESSES))  
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if (( GUESS > VALUE ))
    then
      echo "It's lower than that, guess again:"
    elif (( GUESS < VALUE ))
    then
      echo "It's higher than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

if [[ -z $USERNAME_RESULT ]]
then
  UPDATE_GAME_RESULTS=$($PSQL "update users set games_played=1, best_game=$NUMBER_OF_GUESSES where name='$USERNAME'")
else
  ((++GAMES_PLAYED))
  if (( BEST_GAME > NUMBER_OF_GUESSES ))  
  then
    BEST_GAME=$NUMBER_OF_GUESSES
  fi
  UPDATE_GAME_RESULTS=$($PSQL "update users set games_played=$GAMES_PLAYED, best_game=$BEST_GAME where name='$USERNAME'")
fi
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $VALUE. Nice job!"
