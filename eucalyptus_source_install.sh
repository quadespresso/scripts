#!/bin/bash

if [ "$1" = "" ];
then
  echo "Please provide an argument, e.g frontend or nc"
  exit 1
fi

echo ""

if [ "$1" == "frontend" ]; then
  echo "========================================================"
  echo " Installing the Frontend Components (CLC/Walrus/CC/SC)"
  echo "========================================================"
  read -p "Frontend IP [empty for 10.104.1.154]: " FRONTENDIP
  if [ "$FRONTENDIP" == "" ];
  then
    FRONTENDIP=10.104.1.154
  fi
else
  echo "======================================================"
  echo "                  Installing the NC"
  echo "======================================================"
fi

yum install git -y
git clone git://github.com/eucalyptus/eucalyptus --recursive

yum install http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -y

cat > /etc/yum.repos.d/eucadeps.repo <<EOF
[euca-deps]
name=euca-deps
baseurl= http://downloads.eucalyptus.com/software/eucalyptus/build-deps/3.2/rhel/6/x86_64
gpgcheck=0
enabled=1

[euca-runtime]
name=euca-rundeps
baseurl= http://downloads.eucalyptus.com/software/eucalyptus/runtime-deps/3.1/rhel/6/x86_64
gpgcheck=0
enabled=1

[euca2ools]
name=euca2ools
baseurl= http://downloads.eucalyptus.com/software/euca2ools/2.1/centos/6/x86_64
gpgcheck=0
enabled=1
EOF

if [ "$1" == "frontend" ];
then
  yum install http://elrepo.org/linux/elrepo/el6/x86_64/RPMS/elrepo-release-6-4.el6.elrepo.noarch.rpm -y
  yum install java-1.7.0-openjdk java-1.7.0-openjdk-devel gcc make ant ant-nodeps axis2-adb-codegen axis2-codegen axis2c-devel jpackage-utils libvirt-devel libxml2-devel libxslt-devel python-devel python-setuptools rampartc-devel swig velocity xalan-j2-xsltc gawk java-devel java-devel openssl-devel curl-devel axis2c dhcp41 dhcp41-common postgresql91 postgresql91-server python-boto rampartc iscsi-initiator-utils perl-Crypt-OpenSSL-RSA perl-Crypt-OpenSSL-Random sudo which jpackage-utils java lvm2 velocity drbd83 drbd83-kmod drbd83-utils drbd euca2ools bitstream-vera-fonts dejavu-serif-fonts bridge-utils iptables vtun device-mapper coreutils e2fsprogs file parted util-linux rsync PyGreSQL libcurl curl httpd scsi-target-utils vconfig wget patch -y
else
  yum install java-1.7.0-openjdk java-1.7.0-openjdk-devel gcc make ant ant-nodeps axis2-adb-codegen axis2-codegen axis2c-devel jpackage-utils libvirt-devel libxml2-devel libxslt-devel python-devel python-setuptools rampartc-devel swig velocity xalan-j2-xsltc gawk java-devel java-devel openssl-devel curl-devel axis2c python-boto rampartc iscsi-initiator-utils perl-Crypt-OpenSSL-RSA perl-Crypt-OpenSSL-Random sudo which jpackage-utils java lvm2 velocity drbd83 drbd83-kmod drbd83-utils drbd euca2ools bitstream-vera-fonts dejavu-serif-fonts bridge-utils iptables vtun device-mapper coreutils e2fsprogs file parted util-linux rsync PyGreSQL libcurl curl httpd libvirt scsi-target-utils vconfig wget kvm patch -y
fi

wget --no-check-certificate http://raw.github.com/eucalyptus/eucalyptus-rpmspec/master/euca-WSDL2C.sh -O /opt/euca-WSDL2C.sh

if [ "$1" == "nc" ];
then
  wget --no-check-certificate https://raw.github.com/eucalyptus/eucalyptus/master/tools/eucalyptus-nc-libvirt.pkla -O /var/lib/polkit-1/localauthority/10-vendor.d/eucalyptus-nc-libvirt.pkla
fi

if [ "$1" == "nc" ];
then
  useradd -G kvm eucalyptus
else
  adduser eucalyptus
fi

if [ "$1" == "nc" ];
then
  modprobe kvm_intel
  modprobe vhost_net
fi

export EUCALYPTUS="/opt"

cd eucalyptus

if [ "$1" == "frontend" ];
then
  ./configure '--with-axis2=/usr/share/axis2-*' --with-axis2c=/usr/lib64/axis2c --prefix=$EUCALYPTUS --with-apache2-module-dir=/usr/lib64/httpd/modules --with-db-home=/usr/pgsql-9.1 --with-wsdl2c-sh=/opt/euca-WSDL2C.sh
else
  ./configure '--with-axis2=/usr/share/axis2-*' --with-axis2c=/usr/lib64/axis2c --prefix=$EUCALYPTUS --with-apache2-module-dir=/usr/lib64/httpd/modules --with-wsdl2c-sh=/opt/euca-WSDL2C.sh
fi

make clean ; make; make install

# need to make sure configure eucalyptus.conf first

cp /opt/etc/eucalyptus/eucalyptus.conf /opt/etc/eucalyptus/eucalyptus.conf.bak
echo "" > /opt/etc/eucalyptus/eucalyptus.conf

if [ "$1" == "frontend" ];
then
  cat > /opt/etc/eucalyptus/eucalyptus.conf <<EOF
EUCALYPTUS="/opt"
EUCA_USER="eucalyptus"
CLOUD_OPTS=""
CREATE_SC_LOOP_DEVICES=256
LOGLEVEL="DEBUG"
NC_PORT="8775"
CC_PORT="8774"
SCHEDPOLICY="ROUNDROBIN"
NODES=""
NC_SERVICE="axis2/services/EucalyptusNC"
HYPERVISOR="kvm"
USE_VIRTIO_ROOT="1"
USE_VIRTIO_DISK="1"
USE_VIRTIO_NET="1"
INSTANCE_PATH="/opt/var/lib/eucalyptus/instances"
VNET_MODE="MANAGED-NOVLAN"
VNET_PRIVINTERFACE="em2"
VNET_PUBINTERFACE="em1"
VNET_PUBLICIPS="10.104.3.150-10.104.3.160"
VNET_BRIDGE="br0"
VNET_SUBNET="172.16.0.0"
VNET_NETMASK="255.255.0.0"
VNET_ADDRSPERNET="32"
VNET_DNS="8.8.8.8"
VNET_DHCPDAEMON="/usr/sbin/dhcpd41"
VNET_DHCPUSER="dhcpd"
EOF
else
  cat > /opt/etc/eucalyptus/eucalyptus.conf <<EOF
EUCALYPTUS="/opt"
EUCA_USER="eucalyptus"
CLOUD_OPTS=""
LOGLEVEL="DEBUG"
NC_PORT="8775"
CC_PORT="8774"
SCHEDPOLICY="ROUNDROBIN"
NODES=""
NC_SERVICE="axis2/services/EucalyptusNC"
HYPERVISOR="kvm"
USE_VIRTIO_ROOT="1"
USE_VIRTIO_DISK="1"
USE_VIRTIO_NET="1"
CREATE_NC_LOOP_DEVICES=256
INSTANCE_PATH="/opt/var/lib/eucalyptus/instances"
VNET_MODE="MANAGED-NOVLAN"
VNET_BRIDGE="br0"
EOF
fi

echo "" >> ~/.bashrc
echo "PATH=$PATH:/opt/usr/sbin/" >> ~/.bashrc

source ~/.bashrc

euca_conf --setup

if [ "$1" == "frontend" ];
then
  ln -s /opt/etc/init.d/eucalyptus-cloud /etc/init.d/
  ln -s /opt/etc/init.d/eucalyptus-cc /etc/init.d/
else
  ln -s /opt/etc/init.d/eucalyptus-nc /etc/init.d/
fi

ln -s /opt/etc/eucalyptus /etc/eucalyptus
ln -s /opt/var/lib/eucalyptus /var/lib/eucalyptus
ln -s /opt/var/log/eucalyptus /var/log/eucalyptus

if [ "$1" == "frontend" ];
then
  euca_conf --initialize
  service eucalyptus-cloud start
  service eucalyptus-cc start

  curl http://localhost:8443/ >/dev/null 2>&1
  while [ $? -ne 0 ] ; do
    sleep 10
    curl http://localhost:8443/ >/dev/null 2>&1
  done

  euca_conf --register-walrus --partition walrus --host $FRONTENDIP --component walrus00
  sleep 5

  while [ `euca_conf --list-walruses | cut -f 5` != "ENABLED" ]
  do
    sleep 3
  done

  euca_conf --register-cluster --partition cluster00 --host $FRONTENDIP --component cc00
  sleep 5

  while [ `euca_conf --list-clusters | cut -f 5` != "ENABLED" ]
  do
    sleep 5
  done

  euca_conf --register-sc --partition cluster00 --host $FRONTENDIP --component sc00
  sleep 10

  mkdir .euca
  cd .euca/
  euca_conf --get-credentials admin.zip
  unzip admin.zip
  source eucarc
  cd
  echo "source ~/.euca/eucarc" >> ~/.bashrc

  euca-modify-property -p cluster00.storage.blockstoragemanager=overlay
  #euca-modify-property -p cluster00.storage.dasdevice=/dev/vg01

  while [ `euca_conf --list-scs | cut -f 5` != "ENABLED" ]
  do
    sleep 5
  done
  echo ""
  echo "Register NC manually using "euca_conf --register-nc xxx.xxx.xxx.xxx""
fi
