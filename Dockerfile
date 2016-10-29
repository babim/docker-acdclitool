FROM babim/debianbase

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    locales \
    python3-setuptools && \
  easy_install3 -U pip && \
  pip3 install --upgrade git+https://github.com/yadayada/acd_cli.git && \
  apt-get -y purge git && \
  apt-get -y autoremove --purge && apt-get autoclean && apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /cache && mkdir /root/.cache && ln -s /cache /root/.cache/acd_cli
VOLUME ["/cache", "/home"]

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
