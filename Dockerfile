# We build our own busybox-static with musl, because the default
# debian one links to glibc, and glibc implements rfc3484, and
# "rule 9" of that rfc is grossly incompatible with kube headless
# services.  We would like to start a discussion about all this
# on the glibc mailing list, and for that we need nilcons-debian to
# contain both glibc based (normal) and musl based (busybox) wget,
# for demonstration purposes.
#
# Once this rfc3484 based glibc behaviour is fixed, we can remove this
# hack and go back to using normal busybox-static from debian.
#
# The busybox config sed hacks are there, because otherwise it doesn't
# compile with musl.
FROM debian:trixie AS busybox-build
RUN </etc/apt/sources.list.d/debian.sources sed s/deb$/deb-src/ >/etc/apt/sources.list.d/debian-src.sources
RUN apt-get update -q && apt-get install -y build-essential musl-tools && apt-get build-dep -y busybox
RUN ln -s /usr/include/linux /usr/include/asm-generic /usr/include/$(dpkg-architecture -q DEB_BUILD_GNU_TYPE)/asm /usr/include/*-musl*
RUN mkdir /tmp/bb && cd /tmp/bb \
        && apt-get source busybox \
        && mv /tmp/bb/busybox-* /tmp/bb/busybox \
        && cd /tmp/bb/busybox \
        && mkdir build-musl && cat debian/config/os/linux debian/config/pkg/static >build-musl/.config \
        && sed -i s/CONFIG_EXTRA_COMPAT=y/CONFIG_EXTRA_COMPAT=n/ build-musl/.config \
        && sed -i s/CONFIG_FEATURE_VI_REGEX_SEARCH=y/CONFIG_FEATURE_VI_REGEX_SEARCH=n/ build-musl/.config \
        && sed -i s/CONFIG_SYSLOGD=y/CONFIG_SYSLOGD=n/ build-musl/.config \
        && sed -i s/CONFIG_UBIRENAME=y/CONFIG_UBIRENAME=n/ build-musl/.config \
        && yes "" | make CC=musl-gcc LD=musl-gcc -C build-musl -f $PWD/Makefile KBUILD_SRC=$PWD oldconfig \
        && make CC=musl-gcc LD=musl-gcc -C build-musl -f $PWD/Makefile KBUILD_SRC=$PWD

FROM debian:trixie
RUN apt-get update -q \
        && apt-get install -y -q --no-install-recommends \
           lsof procps net-tools dnsutils moreutils unzip zip strace iotop ca-certificates psmisc file \
           netcat-openbsd telnet curl socat tcpdump wget bwm-ng ssh-client openssl links bind9-dnsutils iproute2 mtr-tiny iputils-ping iptables fping \
           less vim git ed tmux mc calc bc ncdu dstat smem pv jq man-db sqlite3 fdisk dosfstools \
           bzip2 xz-utils lzip lzma lzop gzip ncompress zstd \
           rsync python3 \
           busybox-static tini \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
COPY bash-if-tty tini-if-1 /usr/bin/
RUN dpkg-divert --rename --add /usr/bin/busybox
COPY --from=busybox-build  /tmp/bb/busybox/build-musl/busybox /usr/bin/busybox
ENTRYPOINT [ "/usr/bin/tini-if-1" ]
CMD [ "/usr/bin/bash-if-tty" ]

# Unit test: docker run -it --rm ttl.sh/nilcons/debian /bin/sh -c 'for i in `seq 1 10` ; do echo $i ; done ; exec sleep 100'
