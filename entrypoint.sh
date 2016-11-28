#!/bin/sh

# overwrite /etc/fuse.conf to allow other users to access the mounted filesystem from outside the container
cat <<EOF> /etc/fuse.conf
# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
user_allow_other
EOF

# set env for ACDCLI
ACD_CLI_CACHE_PATH=/cache
ENV ACD_CLI_SETTINGS_PATH=/cache

# set ID docker run
auid1=${auid:-1000}
agid1=${agid:-1000}

if [[ "$auid1" = "0" ]] || [[ "$aguid1" == "0" ]]; then
  echo "Run in ROOT user"
else
  echo "Run in user"
  if [ ! -d "/home/user" ]; then
  groupadd --gid ${agid1} user && \
  useradd --uid ${auid1} --gid ${agid1} --create-home user
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

# stop wait command
sh
