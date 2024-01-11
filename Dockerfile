FROM debian:bookworm
RUN apt-get update -q \
        && apt-get install -y -q --no-install-recommends \
           lsof procps net-tools dnsutils moreutils unzip zip strace iotop ca-certificates psmisc file \
           netcat-openbsd telnet curl socat tcpdump wget bwm-ng ssh-client openssl links bind9-dnsutils iproute2 mtr-tiny iputils-ping \
           less vim git ed tmux mc apcalc bc ncdu dstat smem pv jq man-db sqlite3 \
           rsync python3 \
           busybox-static tini \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
ENTRYPOINT [ "tini", "--" ]
COPY bash-if-tty /usr/bin
CMD [ "/usr/bin/bash-if-tty" ]

# Unit test: docker run -it --rm ttl.sh/nilcons/debian /bin/sh -c 'for i in `seq 1 10` ; do echo $i ; done ; exec sleep 100'
