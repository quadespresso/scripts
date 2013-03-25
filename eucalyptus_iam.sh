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
#   Setup multiple IAM acounts on Eucalyptus - 0.1

NAME="batman"
SET=2

# create two account
for x in `seq $SET`;
do
  euare-accountcreate -a $NAME$x
  mkdir $NAME$x
  cd $NAME$x

  # download other account credentials
  euca_conf --cred-account $NAME$x --cred-user admin --get-credentials $NAME$x.zip
  
  # unzip and source creds
  unzip $NAME$x.zip; source eucarc

  # create two users
  for i in `seq $SET`;
  do
    euare-usercreate -u $NAME$x-user$i -p /$NAME$x
    mkdir $NAME$x-user$i; cd $NAME$x-user$i;

    euare-useraddloginprofile -u $NAME$x-user$i -p $NAME$x
    
    # download other account credentials
    euca_conf --cred-account $NAME$x --cred-user $NAME$x-user$i --get-credentials $NAME$x-user$i.zip
    unzip $NAME$x-user$i.zip
    cd ..
  done

  # list of users
  euare-userlistbypath
  cd
  source ~/.euca/eucarc
done

# list of accounts
euare-accountlist

# change password for login profile
#euare-usermodloginprofile -u admin -p shaon2
