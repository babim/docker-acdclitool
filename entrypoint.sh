#!/bin/sh

# overwrite /etc/fuse.conf to allow other users to access the mounted filesystem from outside the container
cat <<EOF> /etc/fuse.conf
# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
user_allow_other
EOF

# set env for ACDCLI
export CONFIGPATH=${CONFIGPATH:-/cache}
export CACHEPATH=${CACHEPATH:-/cache}
export CLOUDPATH=${CLOUDPATH:-/cloud}
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
WEBDAVPASS=${WEBDAVPASS:-123456}

# Only allow read access by default
READWRITE=${READWRITE:=false}

# Add user if it does not exist
if ! id -u "${USERNAME}" >/dev/null 2>&1; then
	addgroup -g ${USER_GID:=2222} ${GROUP}
	adduser -G ${GROUP} -D -H -u ${USER_UID:=2222} ${USERNAME}
fi

chown webdav /var/log/lighttpd

# create config for webdav
if [ ! -f "$CONFIGPATH/lighttpd.conf" ]; then
# create
cat <<EOF>> $CONFIGPATH/lighttpd.conf
server.modules = (
    "mod_access",
    "mod_accesslog",
    "mod_webdav",
    "mod_auth"
)

include "/etc/lighttpd/mime-types.conf"
server.username       = "$USERNAME"
server.groupname      = "$GROUP"

server.document-root  = "$CLOUDPATH"

server.pid-file       = "/run/lighttpd.pid"
server.follow-symlink = "enable"

# No errorlog specification to keep the default (stderr) and make sure lighttpd
# does not try closing/reopening. And redirect all access logs to a pipe. See
# https://redmine.lighttpd.net/issues/2731 for details
accesslog.filename    = "/tmp/lighttpd.log"
#Omitting the following on purpose
#server.errorlog       = "/dev/stderr"

include "$CONFIGPATH/webdav.conf"
EOF
fi

# create config for webdav
if [ ! -f $CONFIGPATH/webdav.conf ]; then
cat <<'EOF'>> $CONFIGPATH/webdav.conf
$HTTP["remoteip"] !~ "WHITELIST" {

  # Require authentication
  $HTTP["host"] =~ "." {
EOF
cat <<EOF>> $CONFIGPATH/webdav.conf
    server.document-root = "$CLOUDPATH"

    webdav.activate = "enable"
    webdav.is-readonly = "disable"
    webdav.sqlite-db-name = "/locks/lighttpd.webdav_lock.db" 

    auth.backend = "htpasswd"
    auth.backend.htpasswd.userfile = "/cache/htpasswd"
    auth.require = ( "" => ( "method" => "basic",
                             "realm" => "webdav",
                             "require" => "valid-user" ) )
  }

}
EOF
cat <<'EOF'>> $CONFIGPATH/webdav.conf
else $HTTP["remoteip"] =~ "WHITELIST" {

  # Whitelisted IP, do not require user authentication
  $HTTP["host"] =~ "." {
EOF
cat <<EOF>> $CONFIGPATH/webdav.conf
    server.document-root = "$CLOUDPATH"

    webdav.activate = "enable"
    webdav.is-readonly = "disable"
    webdav.sqlite-db-name = "/locks/lighttpd.webdav_lock.db" 
  }

}
EOF
fi

if [ ! -f $CONFIGPATH/htpasswd ]; then
cat <<EOF>> $CONFIGPATH/htpasswd
webdav:$WEBDAVPASS
EOF
fi

if [ -n "$WHITELIST" ]; then
	sed -i "s/WHITELIST/${WHITELIST}/" $CONFIGPATH/webdav.conf
fi

if [ "$READWRITE" = true ]; then
	sed -i "s/readonly = \"disable\"/readonly = \"enable\"/" $CONFIGPATH/webdav.conf
fi

lighttpd -f $CONFIGPATH/lighttpd.conf

# Hang on a bit while the server starts
sleep 2

# stop and wait command
sh
