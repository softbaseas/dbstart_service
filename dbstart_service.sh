#!/usr/bin/bash
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

#echo "List of existing Oracle Homes:"
#echo "------------------------------"
#cat `cat /etc/oraInst.loc|grep inventory_loc|cut -d '=' -f2` /ContentsXML/inventory.xml|grep "HOME NAME"|cut -d `"` -f 4
#echo
