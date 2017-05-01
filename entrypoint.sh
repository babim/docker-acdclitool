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
if [ ! -d "$CONFIGPATH" ]; then mkdir -p $CONFIGPATH; fi
if [ ! -d "$CACHEPATH" ]; then mkdir -p $CACHEPATH; fi

export ACD_CLI_CACHE_PATH=$CACHEPATH
export ACD_CLI_SETTINGS_PATH=$CONFIGPATH
export HTTPS_PROXY="$PROXY"
export HTTP_PROXY="$PROXY"

# set ID docker run
auid=${auid:-1000}
agid=${agid:-$auid}
auser=${auser:-user}

if [[ "$auid" = "0" ]] || [[ "$agid" == "0" ]]; then
  echo "Run in ROOT user"
else
  echo "Run in $auser"
  if [ ! -d "/home/$auser" ]; then
  addgroup -g ${agid} $auser && \
  adduser -D -u ${auid} -G $auser $auser && \
  mkdir -p /home/$auser/.cache/acd_cli #no need
  ln -sf $CACHEPATH /home/$auser/.cache/acd_cli #no need
  chown -R $auid:$agid /home/$auser #no need
  chown -R $auid:$agid $CONFIGPATH $CACHEPATH
  # fix su command user
  sed -i '$ d' /etc/passwd
  echo "$auser:x:$auid:$agid:Linux User:/home/$auser:/bin/sh" >> /etc/passwd
  fi
  su - $auser
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
