FROM babim/alpinebase

# create dirs for the config, local mount point, and cloud destination
#RUN mkdir /config /cache /data /cloud
RUN mkdir /cache /data /cloud

# set the cache, settings, and libfuse path accordingly
ENV ACD_CLI_CACHE_PATH /cache
ENV ACD_CLI_SETTINGS_PATH /cache
ENV LIBFUSE_PATH /usr/lib/libfuse.so.2

# install python 3, fuse, and git
RUN apk add --no-cache python3 fuse git && pip3 install --upgrade pip

# install acd_cli
RUN pip3 install --upgrade git+https://github.com/yadayada/acd_cli.git

# no need for git or the apk cache anymore
RUN apk del git

#VOLUME ["/config", "/cache", "/data", "/cloud"]
VOLUME ["/cache", "/data", "/cloud"]

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
