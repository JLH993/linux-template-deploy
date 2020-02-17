#!/bin/bash

## Use case: Deploying from CentOS/RHEL 7.x template in a virtual environment.
## Written by https://github.com/JLH993/ Jason Hensley Feb 2019. 
## If there is an issue, please create one on Github for proper tracking.

# global variables...
DATE=`date +%x`
DAY=$(date '+DATE: %m/%d/%y%tTIME:%H:%M:%S')
NC='\033[0m' # No Color
GREEN='\033[0;32m'
RED='\033[0;31m'
TMP='/root/tmp/'
LOG='/root/tmp/configure.log'

# script must be ran as root, check and inform...
	if [ "$(id -u)" != "0" ]; then
   		echo "This script must be run as root" 1>&2
   		exit 1
	fi
        
# does log file/tmp directory exist? if not, create it.
( [ -e "$LOG" ] || touch "$LOG" ) && [ ! -w "$LOG" ] && echo cannot write to $LOG && exit 1
( [ -e "$TMP" ] || mkdir -p "$TMP" )

# set hostname...
configure-hostname() {
echo -n "Enter short hostname and press [ENTER]: "
read HSTNM
echo -n "Enter domain name (leave blank if N/A) and press [ENTER]: "
read DOMAIN

# define FQDN and sanity check...
FQDN=$HSTNM.$DOMAIN
echo -e "${GREEN}New hostname: $FQDN ${NC}"
read -p "Is this correct? Yy/Nn: " -n 1 -r
}

configure-hostname
echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]
    then
      echo -e "${GREEN}Setting static hostname...${NC}"
        else
      echo -e "${RED}Re-launching hostname configuration...${NC}" && echo -e "${RED}$DATE: Re-running configure-hostname, user input indicated a mistype.${NC}" >> $LOG
    configure-hostname
  fi

hostnamectl --static set-hostname $FQDN && echo -e "${GREEN}$DATE: Hostname successfully configured as:${NC} $FQDN." >> $LOG

# get network interface id...
NICID=`ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}' | tr -d "[:blank:]"`

# configure network interface... 
configure-ip() {
echo -n "Enter static IP address and press [ENTER]: "
read IP
echo -n "Enter Subnet Mask and press [ENTER]: "
read SM
echo -n "Enter Default Gateway and press [ENTER]: "
read GW
echo -n "Enter primary DNS server IP address and press [ENTER]: "
read DNS1
echo -n "Enter secondary DNS server IP address (leave blank if N/A) and press [ENTER]: "
read DNS2

echo ""
echo -e "          ${GREEN}#### PLEASE REVIEW ####${NC}"
echo "          IP address: $IP"
echo "          Netmask: $SM"
echo "          Gateway: $GW"
echo "          Primary DNS: $DNS1"
echo "          Secondary DNS: $DNS2"
echo ""

read -p "Is this correct? Yy/Nn: " -n 1 -r
}

configure-ip
echo
  if [[ $REPLY =~ ^[Yy]$ ]]
    then
      echo -e "${GREEN}Configuring network interface...${NC}"
        else
      echo -e "${RED}Re-launching network configuration...${NC}" && echo -e "${RED}$DATE: Re-running configure-ip, user input indicated a mistype.${NC}" >> $LOG
    configure-ip
  fi

echo "" > /home/ova/tmp/ifcfg-$NICID
echo "TYPE=Ethernet" >> /home/ova/tmp/ifcfg-$NICID
echo "BOOTPROTO=none" >> /home/ova/tmp/ifcfg-$NICID
echo "DEFROUTE=yes" >> /home/ova/tmp/ifcfg-$NICID
echo "NAME=$NICID" >> /home/ova/tmp/ifcfg-$NICID
echo "DEVICE=$NICID" >> /home/ova/tmp/ifcfg-$NICID
echo "ONBOOT=yes" >> /home/ova/tmp/ifcfg-$NICID
echo "IPADDR=$IP" >> /home/ova/tmp/ifcfg-$NICID
echo "NETMASK=$SM" >> /home/ova/tmp/ifcfg-$NICID
echo "GATEWAY=$GW" >> /home/ova/tmp/ifcfg-$NICID
echo "DNS1=$DNS1" >> /home/ova/tmp/ifcfg-$NICID
echo "DNS2=$DNS2" >> /home/ova/tmp/ifcfg-$NICID

/bin/cp -f /home/ova/tmp/ifcfg-$NICID /etc/sysconfig/network-scripts/ifcfg-$NICID && echo -e "${RED}$DATE: Network device $NICID successfully configured." >> $LOG
systemctl restart network
