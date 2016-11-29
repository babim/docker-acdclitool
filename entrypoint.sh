#!/bin/sh

# overwrite /etc/fuse.conf to allow other users to access the mounted filesystem from outside the container
cat <<EOF> /etc/fuse.conf
# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
user_allow_other
EOF

# set env for ACDCLI
CONFIGPATH=${CONFIGPATH:-/cache}
CACHEPATH=${CACHEPATH:-/cache}
if [ ! -d "CONFIGPATH" ]; then mkdir -p CONFIGPATH; fi
if [ ! -d "CACHEPATH" ]; then mkdir -p CACHEPATH; fi

export ACD_CLI_CACHE_PATH=$CACHEPATH
export ACD_CLI_SETTINGS_PATH=$CONFIGPATH
export HTTPS_PROXY="$PROXY"
export HTTP_PROXY="$PROXY"

# set ID docker run
auid=${auid:-1000}
agid=${agid:-1000}

if getent passwd $1 > /dev/null 2>&1; then
    echo "yes the user exists"
else
    echo "No, the user does not exist"
    
if [[ "$auid" = "0" ]] || [[ "$aguid" == "0" ]]; then
  echo "Run in ROOT user"
else
  echo "Run in user"
  if [ ! -d "/home/user" ]; then
  addgroup -g ${agid} user && \
  adduser -D -u ${auid} -G user user && \
  mkdir -p /home/user/.cache/acd_cli #no need
  ln -sf $CACHEPATH /home/user/.cache/acd_cli #no need
  chown -R $auid:$agid /home/user #no need
  fi
  su - user
fi

fi

# help
echo "use acdcli command"
echo "---"
acdcli -h

# create startup run
if [ ! -f "$CONFIGPATH/startup.sh" ]; then
# create
cat <<EOF>> $CONFIGPATH/startup.sh
#!/bin/sh
# your startup command
EOF
  chmod +x $CONFIGPATH/startup.sh
else
# run
  $CONFIGPATH/startup.sh
fi

# stop and wait command
sh
