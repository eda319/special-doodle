#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# truncate all the data for testing
echo $($PSQL "TRUNCATE teams CASCADE;")

# insert teams to the teams table
cat games.csv | while IFS=',' read YEAR _ WINNER OPPONENT _ _
do
  if [[ $YEAR = year ]]
  then 
    continue
  else
    # check if the teams being inserted is already in the database, if it is, then don't insert it;
    EXISTING_WINNER=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER';")
    EXISTING_OPPONENT=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT';")
    if [[ -z $EXISTING_WINNER && -z $EXISTING_OPPONENT ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER'), ('$OPPONENT');"
      continue
    fi
    if [[ -z $EXISTING_WINNER ]]
    then  
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER');"
    fi
    if [[ -z $EXISTING_OPPONENT ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');"
    fi
  fi
done

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR = year ]]
  then 
    continue
  else
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES(
      $YEAR, '$ROUND', (SELECT team_id FROM teams WHERE name = '$WINNER'), (SELECT team_id FROM teams WHERE name = '$OPPONENT'), $WINNER_GOALS, $OPPONENT_GOALS 
    );"
  fi
done
