

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
if [[ -L "/etc/systemd/system/namingservice.service"  ]]; then
  read -p "Service already exist and is activated. Deactivate and delete (y/N)? " yn
  case $yn in
    [Yy]*) systemctl stop namingservice; rm /etc/systemd/system/namingservice.service; rm /usr/lib/systemd/system/namingservice.service ;;
    *) echo "Won't delete."; exit 1 ;;
  esac
fi

if [ -f "/usr/lib/systemd/system/namingservice.service" ]; then
  read -p "Service already exist. Should it be deleted (y/N)? " yn
  case $yn in
    [Yy]*)  systemctl stop namingservice; rm /usr/lib/systemd/system/namingservice.service ;;
    *) echo "Won't delete."; exit 1 ;;
  esac
#fi
  echo "# /etc/systemd/system/namingservice.service
  # Ivan Kartik (ivn.kartik.sk), edit by Anders Wiberg Olsen (www.wiberg.tech)
  #    Invoking Oracle scripts to start/shutdown instances defined in /etc/oratab
  #    and starts listener


  [Unit]
  Description=AdminServer WLS_Forms WLS_Reports
  After=webnm.service

  [Service]
  User=oracle
  Group=oinstall
  Type=forking
  Restart=no
  ExecStart=/home/oracle/WlsScripts/Startnamingservice.sh
  ExecStop=/home/oracle/WlsScripts/Stopnamingservice.sh

  [Install]
  WantedBy=multi-user.target" > /usr/lib/systemd/system/namingservice.service

  systemctl daemon-reload
  systemctl enable namingservice
  echo "Done! Service namingservice.service has been configured and will be started during next boot."
  echo "If you want to start the service now, execute: systemctl start namingservice"
else
  echo "Error: namingservice.service is not installed yet. This script will not work without it, install it before installing this."
  exit 1
fi
