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
#   Setup multiple IAM acounts on Eucalyptus - 0.2

if [ "$1" = "" ];
then
  NAME="batman"
else
  NAME="$1"
fi

if [ "$2" = "" ];
then
  DIR="eucalyptus_iam"
else
  DIR="$2"
fi

PASSWD="123456"
SET=2
EIAMDIR=/root/$DIR

# get admin account creds
mkdir $EIAMDIR
mkdir $EIAMDIR/eucalyptus-admin; cd $EIAMDIR/eucalyptus-admin
euca-get-credentials admin.zip
unzip admin.zip; source eucarc

# create two account
for x in `seq $SET`;
do
  mkdir $EIAMDIR/$NAME$x
  cd $EIAMDIR/$NAME$x
  euare-accountcreate -a $NAME$x

  # download other account credentials, unzip and source creds
  euca-get-credentials -a $NAME$x $NAME$x.zip
  unzip $NAME$x.zip; source eucarc
  euare-useraddloginprofile -u admin -p $PASSWD
  euare-userupdateinfo -k email -i $NAME$x-admin@superhero.net -u admin #eucalyptus only

  cd $EIAMDIR/

  # create two users
  for i in `seq $SET`;
  do
    euare-usercreate -u $NAME$x-user$i -p /$NAME$x
    mkdir $EIAMDIR/$NAME$x-user$i; cd $EIAMDIR/$NAME$x-user$i;

    euare-useraddloginprofile -u $NAME$x-user$i -p $PASSWD
    euare-userupdateinfo -k email -i $NAME$x-user$i@superhero.net -u $NAME$x-user$i #eucalyptus only

    # download other account credentials
    euca-get-credentials -a $NAME$x -u $NAME$x-user$i $NAME$x-user$i.zip
    unzip $NAME$x-user$i.zip
    cd $EIAMDIR/
  done

  # list of users
  euare-userlistbypath
  source $EIAMDIR/eucalyptus-admin/eucarc
done

# list of accounts
euare-accountlist
cd
