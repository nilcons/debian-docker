FROM debian:bookworm
RUN apt-get update -q \
        && apt-get install -y -q --no-install-recommends \
           lsof procps net-tools dnsutils moreutils unzip zip strace iotop ca-certificates psmisc file \
           netcat-openbsd telnet curl socat tcpdump wget bwm-ng ssh-client openssl links bind9-dnsutils \
           less vim git ed tmux mc apcalc bc ncdu dstat smem pv jq man-db \
           rsync python3 \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
