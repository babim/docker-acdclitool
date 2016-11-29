FROM babim/alpinebase

# create dirs for the config, local mount point, and cloud destination
#RUN mkdir /config /cache /data /cloud
RUN mkdir /cache /data /cloud

# set the cache, settings, and libfuse path accordingly
ENV ACD_CLI_CACHE_PATH /cache
ENV ACD_CLI_SETTINGS_PATH /cache
ENV LIBFUSE_PATH /usr/lib/libfuse.so.2
ENV agid 1000
ENV auid 1000

# install python 3, fuse, and git
RUN apk add --no-cache python3 fuse git && pip3 install --upgrade pip

# install acd_cli
RUN pip3 install --upgrade git+https://github.com/yadayada/acd_cli.git

# no need for git or the apk cache anymore
RUN apk del git

# overwrite /etc/fuse.conf to allow other users to access the mounted filesystem from outside the container
RUN sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# create user
RUN addgroup -g ${agid} user && \
    adduser -D -u ${auid} -G user user && \
    mkdir -p /home/user/.cache/acd_cli && \
    ln -s /cache /home/user/.cache/acd_cli && \
    chown -R $uid:$gid /home/user

#VOLUME ["/config", "/cache", "/data", "/cloud"]
VOLUME ["/cache", "/data", "/cloud"]

USER user

ENTRYPOINT ["/usr/bin/acdcli"]
CMD ["-h"]
