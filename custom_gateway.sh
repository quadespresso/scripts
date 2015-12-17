#!/bin/bash

# add custom gateway
# remove default gateway

cat << EOF > /etc/sysconfig/network-scripts/route-em1
10.1.1.254 via 10.111.0.1 dev em1
EOF

grep -q "DEFROUTE=no" /etc/sysconfig/network-scripts/ifcfg-em1 || echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-em1

service network restart
