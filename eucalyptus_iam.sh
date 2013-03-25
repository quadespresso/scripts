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
