#!/bin/bash

auid=${uid:-1000}
agid=${gid:-1000}

if [[ "$auid" =~ [^a-zA-Z] ]] || [[ "$guid" =~ [^a-zA-Z] ]] || [[ "$auid" == *['!'@#\$%^\&*()_+]* ]] || [[ "$guid" == *['!'@#\$%^\&*()_+]* ]]; then
  echo "Wrong value ID! remove this container and recreate"
  exit
fi

if [[ "$auid" = "0" ]] || [[ "$guid" == "0" ]]; then
  echo "Run in ROOT user"
else
  echo "Run in user"
  if [ ! -d "/home/user" ]; then
  groupadd --gid ${gid} user && \
  useradd --uid ${uid} --gid ${gid} --create-home user
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
