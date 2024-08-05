#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MENU() {
  if [[ $1 ]]
  then
    echo -e $1
  fi

  # display service list
  SERVICES=$($PSQL "SELECT * FROM services;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  
  # ask for service
  read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
    # send to menu
    MENU "\nThat is not a valid service number."
  else
    # get service
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # if service not found
    if [[ -z $SERVICE ]]
    then
      # send to menu
      MENU "\nI could not find that service. What would you like today?"
    else
      # get phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      
      # if customer not found
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new customer_name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # insert into customers
        ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      fi

      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # remove spaces from customer and service names
      SERVICE_FORMATTED=$(echo $SERVICE | sed -E 's/^ *| *$//g')
      NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
    
      # get appointment time
      echo -e "\nWhat time would you like for your $SERVICE_FORMATTED, $NAME_FORMATTED?"
      read SERVICE_TIME
      
      # add appointment
      ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME, $NAME_FORMATTED."
    fi
  fi
}

MENU "Welcome to My Salon, how can I help you?\n"