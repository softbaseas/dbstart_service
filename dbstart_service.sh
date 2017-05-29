#!/bin/bash
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit
fi

if [ `ps -e|grep " 1 ?"|cut -d " " -f15` != "systemd" ]; then
  echo "Systemd is not present. Use init.d scripts instead."
  exit 1
else
  echo "Systemd is present."
fi

if [ -z "$ORACLE_HOME" ]; then
  echo "Oracle environment has not been set. Environment script can be found in /home/oracle/"
  exit 1
echo

echo "List of existing Oracle Homes:"
echo "------------------------------"
cat `cat /etc/oraInst.loc|grep inventory_loc|cut -d '=' -f2`/ContentsXML/inventory.xml|grep "HOME NAME"|cut -d '"' -f4
echo

echo "Enter ORACLE_HOME of Oracle Listener [$ORACLE_HOME]:"
read NEWHOME

case "$NEWHOME" in
  "")   ORAHOME="$ORACLE_HOME"; echo "home = $ORACLE_HOME" ;;
  *)    ORAHOME="$NEWHOME" ; echo "home = $NEWHOME" ;;
esac
