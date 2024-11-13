#!/bin/bash

# Define the base URL for the Flask API
BASE_URL="http://localhost:5000/api"

# Flag to control whether to echo JSON output
ECHO_JSON=false

# Parse command-line arguments
while [ "$#" -gt 0 ]; do
  case $1 in
    --echo-json) ECHO_JSON=true ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done


###############################################
#
# Health checks
#
###############################################

# Function to check the health of the service
check_health() {
  echo "Checking health status..."
  curl -s -X GET "$BASE_URL/health" | grep -q '"status": "healthy"'
  if [ $? -eq 0 ]; then
    echo "Service is healthy."
  else
    echo "Health check failed."
    exit 1
  fi
}

# Function to check the database connection
check_db() {
  echo "Checking database connection..."
  curl -s -X GET "$BASE_URL/db-check" | grep -q '"database_status": "healthy"'
  if [ $? -eq 0 ]; then
    echo "Database connection is healthy."
  else
    echo "Database check failed."
    exit 1
  fi
}

###############################################
#
# Meal Management
#
###############################################

# Function to create a meal
create_meal() {
  name=$1
  cuisine=$2
  price=$3
  spice_level=$4

  echo "Creating meal ($name, Cuisine: $cuisine, Price: $price, Spice Level: $spice_level)..."
  response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/create-meal" -H "Content-Type: application/json" \
    -d "{\"meal\":\"$name\", \"cuisine\":\"$cuisine\", \"price\":$price, \"difficulty\":\"$spice_level\"}")
  status_code=${response: -3}
  if [[ "$status_code" -eq 201 ]]; then
    echo "Meal created successfully."
  else
    echo "Failed to create meal."
    exit 1
  fi
}

# Function to delete a meal by ID
delete_meal_by_id() {
  meal_id=$1

  echo "Deleting meal with ID: $meal_id..."
  response=$(curl -s -w "%{http_code}" -X DELETE "$BASE_URL/delete-meal/$meal_id")
  status_code=${response: -3}
  if [ "$status_code" -eq 200 ]; then
    echo "Meal deleted successfully."
  else
    echo "Failed to delete meal."
    exit 1
  fi
}

# Function to get a meal by ID
get_meal_by_id() {
  meal_id=$1

  echo "Getting meal with ID: $meal_id..."
  response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/get-meal-by-id/$meal_id")
  status_code=${response: -3}

  if [[ "$status_code" -eq 200 ]]; then
    echo "Meal retrieved successfully."
    if [ "$ECHO_JSON" = true ]; then
      echo "$response" | jq .
    else
      echo "$response"
    fi
  else
    echo "Failed to get meal."
    exit 1
  fi
  }


############################################################
#
# Combatant & Battle Management
#
############################################################

clear_combatants() {
  echo "Clearing combatants..."
  response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/clear-combatants")
  status_code=${response: -3}
  if [ "$http_status" -eq 200 ]; then
    echo "Combatants cleared successfully."
  else
    echo "Failed to clear combatants"
    echo "Response: $response_body"
    exit 1
  fi
}

prep_combatant() {
  meal_name=$1
  echo "Adding meal with name '$meal_name' as combatant"
  response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/prep-combatant" \
    -H "Content-Type: application/json" \
    -d "{\"meal\": \"$meal_name\"}")
  http_status=${response: -3}

  if [ "$http_status" -eq 200 ]; then
    echo "Combatant added successfully."
  else
    echo "Failed to prep combatant."
    echo "Response: $response"
    exit 1
  fi
 }

battle() {
  echo "Initiating a battle between two combatants..."
  response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/battle")
  http_status=${response: -3}

  if [ "$http_status" -eq 200 ]; then
    echo "Battle completed successfully."
    if [ "$ECHO_JSON" = true ]; then
      echo "Battle results:"
      echo "$response" | jq .
    fi
  else
    echo "Failed to initiate battle."
    echo "Response: $response"
    exit 1
  fi
 }


######################################################
#
# Leaderboard
#
######################################################

# Function to get the meal leaderboard sorted by wins or win percentage
get_leaderboard() {
  sort_by=$1  # Specify "wins" or "win_pct"
  echo "Getting meal leaderboard sorted by $sort_by..."
   response=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/leaderboard?sort=$sort_by")
  http_status=${response: -3}

  if [ "$http_status" -eq 200 ]; then
    echo "Leaderboard retrieved successfully."
    if [ "$ECHO_JSON" = true ]; then
      echo "$response" | jq .
    else
      echo "$response"
    fi
  else
    echo "Failed to get leaderboard."
    exit 1
  fi
}


# Health checks
check_health
check_db


# Create mealscreate_meal "Pasta" "Italian" 25.9 "MED"
create_meal "Hamburger" "American" 10.0 "LOW"
create_meal "Sushi" "Japanese" 30.0 "HIGH"
create_meal "Pizza" "Italian" 12.0 "LOW"
create_meal "Bibimbap" "Korean" 22.0 "MED"
create_meal "Pad Thai" "Thai" 18.0 "MED"


delete_meal_by_id 4

get_meal_by_id 2

#battle
prep_combatant "Hamburger"
#battle
prep_combatant "Sushi"
battle

get_leaderboard "wins"
get_leaderboard "win_pct"


get_meal_by_id 1
get_meal_by_id 2



echo "All tests passed successfully!"
