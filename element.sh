#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Determine if input is a number or string
if [[ $1 =~ ^[0-9]+$ ]]
then
  # Input is atomic number
  QUERY_CONDITION="e.atomic_number=$1"
else
  # Input is symbol or name
  QUERY_CONDITION="e.symbol='$1' OR e.name='$1'"
fi

# Query the database
RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
FROM elements e 
INNER JOIN properties p ON e.atomic_number = p.atomic_number 
INNER JOIN types t ON p.type_id = t.type_id 
WHERE $QUERY_CONDITION")

# Check if element was found
if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
else
  # Parse the result
  IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$RESULT"
  
  # Output the information
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
fi