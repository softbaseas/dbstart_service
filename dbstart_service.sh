#!/bin/bash
# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit
fi

# Check if systemd is present. If not, it's an older system, and init.d has to be used instead.
if [ `ps -e|grep " 1 ?"|cut -d " " -f15` != "systemd" ]; then
  echo "Systemd is not present. Use init.d scripts instead."
  exit 1
else
  echo "Systemd is present."
fi

# Check if the variable $ORACLE_HOME has been set (i.e. if system environment has been set)
if [ -z "$ORACLE_HOME" ]; then
  echo "Oracle environment has not been set. Environment script can be found in /home/oracle/"
  exit 1
fi

echo

# List current Oracle Homes
echo "List of existing Oracle Homes:"
echo "------------------------------"
cat `cat /etc/oraInst.loc|grep inventory_loc|cut -d '=' -f2`/ContentsXML/inventory.xml|grep "HOME NAME"|cut -d '"' -f4
echo

# Show current Oracle Home, if another is correct, ask the user to enter it, otherwise, press enter.
echo "Enter ORACLE_HOME of Oracle Listener [$ORACLE_HOME]:"
read NEWHOME

# See result of above. If user has entered nothing (i.e. just pressed enter), $ORACLE_HOME is used.
case "$NEWHOME" in
  "")   ORAHOME="$ORACLE_HOME"; echo "home = $ORACLE_HOME" ;;
  *)    ORAHOME="$NEWHOME" ; echo "home = $NEWHOME" ;;
esac

# Check if $ORAHOME has been set.
if [ -z "$ORAHOME" ]; then
  echo "Error: Missing value!"
  exit 1
fi
