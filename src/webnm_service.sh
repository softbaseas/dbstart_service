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

# Check if the service already exists
if [[ -L "/etc/systemd/system/webnm.service"  ]]; then
  read -p "Service already exist and is activated. Deactivate and delete (y/N)? " yn
  case $yn in
    [Yy]*) systemctl stop webnm; rm /etc/systemd/system/webnm.service; rm /usr/lib/systemd/system/webnm.service ;;
    *) echo "Won't delete."; exit 1 ;;
  esac
fi

if [ -f "/usr/lib/systemd/system/webnm.service" ]; then
  read -p "Service already exist. Should it be deleted (y/N)? " yn
  case $yn in
    [Yy]*)  systemctl stop webnm; rm /usr/lib/systemd/system/webnm.service ;;
    *) echo "Won't delete."; exit 1 ;;
  esac
fi
# Check if oracle-rdbms exists. If it does, create systemd script.
if [ -f /usr/lib/systemd/system/oracle-rdbms.service ]; then
  echo "# /etc/systemd/system/oracle-rdbms.service
  # Ivan Kartik (ivn.kartik.sk), edit by Anders Wiberg Olsen (www.wiberg.tech)
  #    Invoking Oracle scripts to start/shutdown instances defined in /etc/oratab
  #    and starts listener

  [Unit]
  Description=Oracle Database(s) and Listener
  Requires=network.target

  [Service]
  User=oracle
  Type=forking
  Restart=no
  ExecStart=/home/oracle/WlsScripts/Startup.sh
  ExecStop=/home/oracle/WlsScripts/Shutdown.sh

  [Install]
  WantedBy=oracle-rdbms.service" > /usr/lib/systemd/system/webnm.service

  systemctl daemon-reload
  systemctl enable webnm
  echo "Done! Service oracle-rdbms has been configured and will be started during next boot."
  echo "If you want to start the service now, execute: systemctl start webnm"
else
  echo "Error: webnm.service is not installed yet. This script will not work without it, install it before installing this."
  exit 1
fi
