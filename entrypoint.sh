#!/bin/sh

# overwrite /etc/fuse.conf to allow other users to access the mounted filesystem from outside the container
cat <<EOF> /etc/fuse.conf
# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
user_allow_other
EOF

# set env for ACDCLI
export ACD_CLI_CACHE_PATH=/cache
export ACD_CLI_SETTINGS_PATH=/cache
export HTTPS_PROXY="$PROXY"

# set ID docker run
auid=${auid:-1000}
agid=${agid:-1000}

if [[ "$auid1" = "0" ]] || [[ "$aguid1" == "0" ]]; then
  echo "Run in ROOT user"
else
  echo "Run in user"
  if [ ! -d "/home/user" ]; then
  addgroup -g ${agid} user && \
  adduser -D -u ${auid} -G user user && \
  mkdir -p /home/user/.cache/acd_cli
  ln -s /cache /home/user/.cache/acd_cli
  chown -R $uid:$gid /home/user
  fi
  su - user
fi

# help
echo "use acdcli command"
echo "---"
acdcli -h

# create startup run
if [ ! -f "/config/startup.sh" ]; then
# create
cat <<EOF>> /config/startup.sh
#!/bin/sh
# your startup command
EOF
  chmod +x /config/startup.sh
else
# run
  /config/startup.sh
fi

# stop and wait command
sh
