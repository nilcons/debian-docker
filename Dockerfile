FROM debian
RUN apt-get update -q \
        && apt-get install -y -q --no-install-recommends procps less lsof net-tools tcpdump \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
