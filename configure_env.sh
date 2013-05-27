#!/bin/bash

# This script is for configuring server
# environment before installing Eucalyptus.
# This is tested on CentOS 6.3 x86_64

if [ "$1" = "" ];
then
  echo "Please provide an argument, e.g frontend or nc"
  exit 1
fi

TURNOFFIPTABLES="n"
REBOOT="n"
UPDATE="n"

read -p "Turn off IPTABLES? [n/y]: " TURNOFFIPTABLES
read -p "Do you want to update host OS? [y/n]: " UPDATE
read -p "Do you want to reboot in end of configuration? [y/n]: " REBOOT
echo ""

if [ "$1" == "frontend" ]; then
  HWADDR_SECONDARY=`ifconfig -a | grep -v em1 | grep -i hwaddr | awk '{print $5}'`
  PUBIP=`ifconfig | grep "inet\ addr" | grep -v 127 | awk '{print $2}' | cut -d: -f2`

  echo -e 'Public IP' $PUBIP 
  read -p 'Local/Internal IP: ' LOCALIP

  cat > /etc/sysconfig/network-scripts/ifcfg-em2 <<EOF
DEVICE=em2
ONBOOT=yes
HWADDR=$HWADDR_SECONDARY
BOOTPROTO=static
IPADDR=$LOCALIP
NETMASK=255.255.0.0
EOF

  echo "NOZEROCONF=yes" >> /etc/sysconfig/network
fi

if [ "$1" == "nc" ]; then
  HWADDR_SECONDARY=`ifconfig -a | grep -v em1 | grep -i hwaddr | awk '{print $5}'`
  cat > /etc/sysconfig/network-scripts/ifcfg-em2 <<EOF
DEVICE=em2
ONBOOT=yes
HWADDR=$HWADDR_SECONDARY
BRIDGE=br0
EOF

  PUBIP=`ifconfig | grep "inet\ addr" | grep -v 127 | awk '{print $2}' | cut -d: -f2`
  echo -e 'Public IP' $PUBIP 
  read -p 'Local/Internal IP: ' LOCALIP
  cat > /etc/sysconfig/network-scripts/ifcfg-br0 <<EOF
DEVICE="br0"
TYPE=Bridge
BOOTPROTO=static
IPADDR=$LOCALIP
NETMASK=255.255.0.0
EOF

  rm -f /etc/sysconfig/network-scripts/ifcfg-em1
  echo "NOZEROCONF=yes" >> /etc/sysconfig/network
fi

service network restart

lvresize --verbose -L 200G /dev/vg01/lv_root
resize2fs /dev/vg01/lv_root


echo ""
echo "Flushing IPTABLES.."
echo ""

iptables -F

echo ""
echo "Saving IPTABLES.."
echo ""

if [ $TURNOFFIPTABLES = "y" ]
then
	service iptables save
	service iptables restart
	chkconfig iptables off
fi

echo ""
echo "Starting NTP.."
echo ""

service ntpd start
chkconfig ntpd on
ntpdate -u pool.ntp.org

echo ""
echo "Updating OS.."
echo ""

if [ $UPDATE = "y" ]
then
	yum update -y
fi

if [ $REBOOT = "y" ]
then
	reboot
fi
