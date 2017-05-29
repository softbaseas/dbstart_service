#!/bin/bash
echo "Choose one of the following possibilities:"
echo " 1 - Create the dbstart service."
echo " 2 - Create the webnm service."
echo " q - Exit"

while true; do
  read -p "Choice: " choice
  case $choice in
    [1]*)  ./src/dbstart_service.sh ;;
    [2]*) ./src/webnm_service.sh ;;
    [q]*) exit 0 ;;
  esac
done
