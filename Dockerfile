FROM babim/debianbase

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    locales \
    python3-setuptools && \
  easy_install3 -U pip && \
  pip3 install --upgrade git+https://github.com/yadayada/acd_cli.git && \
  apt-get -y purge git && \
  apt-get -y autoremove --purge && \
  rm -rf /var/lib/apt/lists/*

ADD entry.sh /entry.sh
RUN chmod +x /entry.sh

ENTRYPOINT ["/entry.sh"]
