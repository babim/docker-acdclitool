FROM babim/alpinebase

# set the cache, settings, and libfuse path accordingly
ENV ACD_CLI_CACHE_PATH /cache
ENV ACD_CLI_SETTINGS_PATH /cache
ENV LIBFUSE_PATH /usr/lib/libfuse.so.2
ENV auid 1000
ENV agid 1000

## alpine linux
RUN apk add --no-cache wget bash && cd / && wget --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh && \
    chmod 755 /option.sh

# install
RUN wget --no-check-certificate -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20acdcli%20install/acdcli_install.sh | bash

#VOLUME ["/config", "/cache", "/data", "/cloud"]
VOLUME ["/cache", "/data", "/cloud"]

USER user
ENTRYPOINT ["/entrypoint.sh"]