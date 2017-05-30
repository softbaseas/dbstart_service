#!/bin/bash

# Check if script is run as root.
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

# Check if the service already exists
if [[ -L "/etc/systemd/system/oracle-rdbms.service"  ]]; then
  read -p "Service already exist and is activated. Deactivate and delete (y/N)? " yn
  case $yn in
    [Yy]*) systemctl stop oracle-rdbms; rm /etc/systemd/system/oracle-rdbms.service; rm /usr/lib/systemd/system/oracle-rdbms.service ;;
    *) echo "Won't delete."; exit 1 ;;
  esac
fi

if [ -f "/usr/lib/systemd/system/oracle-rdbms.service" ]; then
  read -p "Service already exist. Should it be deleted (y/N)? " yn
  case $yn in
    [Yy]*)  systemctl stop oracle-rdbms; rm /usr/lib/systemd/system/oracle-rdbms.service ;;
    *) echo "Won't delete."; exit 1 ;;
  esac
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
  "")   ORAHOME="$ORACLE_HOME" ;;
  *)    ORAHOME="$NEWHOME" ;;
esac

# Check if $ORAHOME has been set.
if [ -z "$ORAHOME" ]; then
  echo "Error: Missing value!"
  exit 1
fi

# Check if lsnrctl exists. If it does, create systemd script.
if [ -f $ORAHOME/bin/lsnrctl ]; then
  echo "# /etc/systemd/system/oracle-rdbms.service
  # Ivan Kartik (ivn.kartik.sk), edit by Anders Wiberg Olsen (www.wiberg.tech)
  #    Invoking Oracle scripts to start/shutdown instances defined in /etc/oratab
  #    and starts listener

  [Unit]
  Description=Oracle Database(s) and Listener
  Requires=network.target

  [Service]
  User=oracle
  Group=oinstall
  Type=forking
  Restart=no
  ExecStart=$ORAHOME/bin/dbstart $ORAHOME
  ExecStop=$ORAHOME/bin/dbshut $ORAHOME
  TimeoutSec=20m0s

  [Install]
  WantedBy=multi-user.target" > /usr/lib/systemd/system/oracle-rdbms.service

  systemctl daemon-reload
  systemctl enable oracle-rdbms
  echo "Done! Service oracle-rdbms has been configured and will be started during next boot."
  echo "If you want to start the service now, execute: systemctl start oracle-rdbms"
else
  echo "Error: No Listener script under specified ORACLE_HOME: $ORAHOME"
  exit 1
fi
