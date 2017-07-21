FROM alpine:edge

WORKDIR /data

RUN apk -U add curl cargo portaudio-dev protobuf-dev \
 && cd /root \
 && curl -LO https://github.com/plietar/librespot/archive/master.zip \
 && unzip master.zip \
 && cd librespot-master \
 && cargo build --jobs $(grep -c ^processor /proc/cpuinfo) --release --no-default-features \
 && mv target/release/librespot /usr/local/bin \
 && mkfifo /data/fifo \
 && cd / \
 && apk --purge del curl cargo portaudio-dev protobuf-dev \
 && apk add llvm-libunwind \
 && rm -rf /etc/ssl /var/cache/apk/* /lib/apk/db/* /root/master.zip /root/librespot-master /root/.cargo

ENV SPOTIFY_NAME Docker
ENV SPOTIFY_DEVICE /data/fifo

CMD librespot -n "$SPOTIFY_NAME" -u "$SPOTIFY_USER" -p "$SPOTIFY_PASSWORD" --device "$SPOTIFY_DEVICE"
