#!/bin/bash

# delnet: removes default gateway and adds static gateway
# addnet: reverse what's been done with delnet

if [ "$1" == "delnet" ] ; then
    cat << EOF > /etc/sysconfig/network-scripts/route-em1
    10.1.1.254 via 10.111.0.1 dev em1
EOF

    grep -q "DEFROUTE=no" /etc/sysconfig/network-scripts/ifcfg-em1 || echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-em1

elif [ "$1" == "addnet" ] ; then
    sed -i '/DEFROUTE=no/d' /etc/sysconfig/network-scripts/ifcfg-em1
    rm -f /etc/sysconfig/network-scripts/route-em1
else
    echo "usage: bash <script name> <arg>       possible args: addnet, delnet"
fi

service network restart
