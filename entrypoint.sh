#!/bin/bash

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

echo "use acdcli command"
echo "---"
acdcli -h
bash
