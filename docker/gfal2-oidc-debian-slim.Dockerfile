FROM debian:bookworm-slim AS oidc-builder
ENV BIN_PATH=/usr/local/oidc-agent
RUN apt-get update && \
    apt-get install -y \
    libcurl4-openssl-dev \
    libsodium-dev \
    libmicrohttpd-dev \
    libsecret-1-dev \
    libqrencode-dev \
    libwebkit2gtk-4.0-dev \
    libcjson-dev \
    git build-essential \
    help2man && \ 
    git clone https://github.com/indigo-dc/oidc-agent && \
    cd oidc-agent && mkdir /usr/local/oidc-agent && \
    make && make install

FROM debian:bookworm-slim AS gfal-builder
RUN apt-get update && \
    apt-get install -y git cmake \
    build-essential libboost-python-dev \
    python3-setuptools gfal2 libgfal2-dev && \
    git clone https://github.com/cern-fts/gfal2-python.git && \
    cd gfal2-python && \
    git checkout tags/v1.11.1 && \
    mkdir build && cd build && cmake .. && \
    make && make install && cd ../.. && \
    mkdir /usr/local/gfal2-util && \
    git clone https://github.com/cern-fts/gfal2-util.git && \
    cd gfal2-util && python3 setup.py install --prefix=/usr/local/gfal2-util
 
FROM debian:bookworm-slim
RUN apt-get update && \
    apt-get install -y \
    libmicrohttpd12 \
    libqrencode4 \
    libsodium23 \
    libsecret-1-0 \
    libcjson1 \
    python3 \
    libboost-python1.74.0 \
    gfal2 \
    man && \
    apt-get clean && \
    ln -s /usr/bin/python3 /usr/bin/python
COPY --from=oidc-builder \
 /usr/local/oidc-agent/bin \
 /usr/local/bin/
COPY --from=gfal-builder \
 /usr/lib/python3/dist-packages/gfal2.so \
 /usr/lib/python3/dist-packages/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/bin \
 /usr/local/bin/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/share/man/man1 \
 /usr/local/share/man/man1/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python3.10/site-packages/gfal2_util \
 /usr/lib/python3.10/gfal2_util/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python3.10/site-packages/gfal2_util-1.8.0-py3.10.egg-info \
 /usr/lib/python3.10/
CMD /bin/bash
