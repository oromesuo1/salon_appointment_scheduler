#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

#echo $($PSQL "TRUNCATE customers, RESTART IDENTITY CASCADE")
echo $($PSQL "TRUNCATE customers, appointment")

echo -e "\n~~~~~ ABC Salon ~~~~~\n"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo "Welcome!"
  fi
  # get available services
 SERVICES
 # SERVICES
 read SERVICE_ID_SELECTED
  #CHOOSE_SERVICE

echo "You entered $SERVICE_ID_SELECTED" 
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid service number, please select from the list."

else
  VALUE=$( CHECK_VALUE $SERVICE_ID_SELECTED )
  if [[ $VALUE == 5 ]]
  then
  MAIN_MENU "Please choose a number from the list."
  elif [[ $VALUE == FOUND ]]
  then 
  BOOK_A_SERVICE
  fi
fi

}

SERVICES() {
  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo -e "\nHere are the services we have available:"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"   
    done 
   
}

CHECK_VALUE() {
    AVAILABLE_SERVICES_ID=$($PSQL "SELECT service_id FROM services")
    #echo "$AVAILABLE_SERVICES_ID"
    SRV_COUNT=$($PSQL "SELECT COUNT(service_id) FROM services")
    #echo "Services count: $SRV_COUNT"
    COUNT=0
    echo "$AVAILABLE_SERVICES_ID" | while read SERVICE_ID
    do
    if [[ $SERVICE_ID != $1 ]]
    then
      COUNT=$(($COUNT + 1))
      if [[ $COUNT == 5 ]]
      then
      echo $COUNT
      fi
    elif [[ $SERVICE_ID == $1 ]]
    then
      echo "FOUND"
    fi

    done

}



# # echo ${SERVICES_ARR[@]}
BOOK_A_SERVICE () {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # get customer name
  CUSTOMER_PHONE_FROM_DB=$($PSQL "SELECT phone from customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_PHONE_FROM_DB ]]
    then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
      # Insert the new customer into the database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
    then
    echo -e "\nInserted customer, $CUSTOMER_NAME"
    fi
  
  fi
    # Ask customer to choose a service time
  echo -e "\nWhat time would you prefer?"
  read SERVICE_TIME
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo "$CUSTOMER_ID"
  # Create appointment
  CREATE_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, service_id, customer_id) VALUES('$SERVICE_TIME', $SERVICE_ID_SELECTED, $CUSTOMER_ID)")
  echo $CREATE_APPOINTMENT_RESULT
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ $CREATE_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
  echo -e "\nI have put you down for a$SERVICE_SELECTED at $SERVICE_TIME,$CUSTOMER_NAME."
  fi

}

MAIN_MENU


