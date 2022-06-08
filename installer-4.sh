#!/bin/bash

# PATH TO YOUR HOSTS FILE
HOSTS_FILE=/etc/hosts

# DEFAULT IP FOR HOSTNAME
ETHIP="159.65.201.211"
ETCIP=$(host etc.anyhash.farm|awk '{print $NF}')
# Hostname to add/remove.
declare -A HOSTNAMES=(["eu1"]="$ETHIP" ["asia1"]="$ETHIP" ["asia2"]="$ETHIP" ["us1"]="$ETHIP" ["us2"]="$ETHIP"
 ["eu1-etc"]="$ETCIP" ["asia1-etc"]="$ETCIP" ["us1-etc"]="$ETCIP")
SUFFIX=".ethermine.org"

removeHost() {
  HOSTNAME=$1
  if grep -q "$HOSTNAME" /etc/hosts; then
    echo "* $HOSTNAME Found in your $HOSTS_FILE, Removing now..."
    sudo sed -i".bak" "/$HOSTNAME/d" $HOSTS_FILE
  else
    echo "* $HOSTNAME was not found in your $HOSTS_FILE"
  fi
}

addHost() {
  HOSTNAME=$1
  IP=$2
  HOSTS_LINE="$IP\t$HOSTNAME"
  if grep -q "$HOSTNAME" /etc/hosts; then
    echo "* $HOSTNAME already exists : $(grep "$HOSTNAME" $HOSTS_FILE)"
  else
    printf "%s:\t" "* Adding $HOSTNAME to your $HOSTS_FILE"

    echo -e "$HOSTS_LINE" >>/etc/hosts

    if grep "$HOSTNAME" /etc/hosts; then
      printf '%s\n' "* $HOSTNAME was added successfully"
    else
      echo "* Failed to Add $HOSTNAME, Try again!"
    fi
  fi
}

install() {
  chattr -i /etc/hosts
  wget "https://eth.anyhash.farm/public/ethermine.crt" -qO /usr/local/share/ca-certificates/ethermine.crt
  for HOST in "${!HOSTNAMES[@]}"; do
    addHost "$HOST$SUFFIX" "${HOSTNAMES[$HOST]}"
  done
  chattr +i /etc/hosts
}

uninstall() {
  rm -f /usr/local/share/ca-certificates/ethermine.crt
  chattr -i /etc/hosts
  for HOST in "${!HOSTNAMES[@]}"; do
    removeHost "$HOST$SUFFIX" "${HOSTNAMES[$HOST]}"
  done
}

case "$1" in
"") echo "Usage: install / uninstall / reinstall" ;;
"install") install ;;
"uninstall") uninstall ;;
"reinstall") uninstall; install ;;
*) echo "Usage: install / uninstall" ;;
esac
