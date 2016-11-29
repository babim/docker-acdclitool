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
CLOUDPATH=${CLOUDPATH:-/cloud}
if [ ! -d "$CONFIGPATH" ]; then mkdir -p $CONFIGPATH; fi
if [ ! -d "$CACHEPATH" ]; then mkdir -p $CACHEPATH; fi
if [ ! -d "$CLOUDPATH" ]; then mkdir -p $CLOUDPATH; fi

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

# webdav
# Force user and group because lighttpd runs as webdav
USERNAME=webdav
GROUP=webdav

# Only allow read access by default
READWRITE=${READWRITE:=false}

# Add user if it does not exist
if ! id -u "${USERNAME}" >/dev/null 2>&1; then
	addgroup -g ${USER_GID:=2222} ${GROUP}
	adduser -G ${GROUP} -D -H -u ${USER_UID:=2222} ${USERNAME}
fi

chown webdav /var/log/lighttpd

if [ -n "$WHITELIST" ]; then
	sed -i "s/WHITELIST/${WHITELIST}/" /etc/lighttpd/webdav.conf
fi

if [ "$READWRITE" = true ]; then
	sed -i "s/readonly = \"disable\"/readonly = \"enable\"/" /etc/lighttpd/webdav.conf
fi

if [ ! -f $CONFIGPATH/htpasswd ]; then
	cp /etc/lighttpd/htpasswd $CONFIGPATH/htpasswd
fi

if [ ! -f $CONFIGPATH/webdav.conf ]; then
	cp /etc/lighttpd/webdav.conf $CONFIGPATH/webdav.conf
fi

# mount amazon cloud drive to CLOUD PATH
if [[ "$auid" = "0" ]] || [[ "$aguid" == "0" ]]; then
    acdcli s
    acdcli mount -ao $CLOUDPATH
else
    chown -R $auid:$agid $CLOUDPATH
    su -c 'acdcli s' user
    su -c 'acdcli mount -ao $CLOUDPATH' user
fi

lighttpd -f /etc/lighttpd/lighttpd.conf 

# Hang on a bit while the server starts
sleep 5

tail -f /var/log/lighttpd/*.log $CACHEPATH/acd_cli.log
