#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~ MY SALON ~~~~\n"
echo Welcome to My Salon, how can I help you?

MAIN_MANU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  # print all services
  echo "$($PSQL "SELECT * FROM services")" | while IFS="|" read SERVICE_ID SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done 
  
  # service select handle
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    1|2|3|4|5) BOOKING;;
    *) MAIN_MANU "I could not find that service. What would you like today?";;
  esac

}

BOOKING() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # get customer name
  CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")"
  if [[ -z $CUSTOMER_NAME ]]
  then
    # new customer handle
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  
  # read booking time
  SELECTED_SERVICE="$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")"
  echo -e "\nWhat time would you like your $SELECTED_SERVICE, $CUSTOMER_NAME?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME." 
}

MAIN_MANU