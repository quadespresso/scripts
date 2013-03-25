#!/bin/bash
#
#   Copyright (C) 2013
#   Imran Hossain Shaon <shaon@eucalyptus.com> / <mdshaonimran@gmail.com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>
#
#   VNC setup on CentOS - 0.1

yum groupinstall Desktop -y

yum install xorg-x11-fonts-100dpi.noarch xorg-x11-fonts-ISO8859-1-100dpi.noarch xorg-x11-fonts-misc.noarch xorg-x11-fonts-Type1.noarch virt-manager tigervnc-server -y

echo ""

echo 'VNCSERVERS="2:root"' >> /etc/sysconfig/vncservers
echo 'VNCSERVERARGS[2]="-geometry 1024x768"' >> /etc/sysconfig/vncservers
echo "Password for vnc server?"
echo ""
vncpasswd

service vncserver start
