FROM bitnami/minideb:bullseye AS oidc-builder
ENV BIN_PATH=/usr/local/oidc-agent
COPY ./assets/conf/gcc.list /etc/apt/sources.list.d/
RUN install_packages \
    libcurl4-openssl-dev \
    libsodium-dev \
    libmicrohttpd-dev \
    libsecret-1-dev \
    libqrencode-dev \
    libwebkit2gtk-4.0-dev \
    git cmake make gcc-11 g++-11 help2man ca-certificates && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 113 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-11 \
    --slave /usr/bin/gcov gcov /usr/bin/gcov-11 \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-11 \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-11 \
    --slave /usr/bin/cpp cpp /usr/bin/cpp-11 \
    --slave /usr/bin/cc cc /usr/bin/gcc-11 && \
    git clone https://github.com/indigo-dc/oidc-agent && \
    cd oidc-agent && mkdir /usr/local/oidc-agent && \
    make && make install

FROM bitnami/minideb:bullseye AS gfal-builder
RUN install_packages libboost-python-dev python3-setuptools && \
    ln -s /usr/bin/python3 /usr/bin/python
COPY ./assets/conf/gcc.list /etc/apt/sources.list.d/
RUN apt-get update && \
    install_packages git cmake \
    make gcc-11 g++-11 ca-certificates \
    gfal2 libgfal2-dev && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 113 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-11 \
    --slave /usr/bin/gcov gcov /usr/bin/gcov-11 \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-11 \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-11 \
    --slave /usr/bin/cpp cpp /usr/bin/cpp-11 \
    --slave /usr/bin/cc cc /usr/bin/gcc-11 && \
    git clone https://github.com/cern-fts/gfal2-python.git && \
    cd gfal2-python && git checkout tags/v1.11.1 && \
    mkdir build && cd build && cmake .. && \
    make && make install && cd ../.. && \
    mkdir /usr/local/gfal2-util && \
    git clone https://github.com/cern-fts/gfal2-util.git && \
    cd gfal2-util && python3 setup.py install --prefix=/usr/local/gfal2-util
 
FROM bitnami/minideb:bullseye
RUN \
    install_packages \
    libcurl4 \
    libmicrohttpd12 \
    libqrencode4 \
    libsodium23 \
    libsecret-1-0 \
    python3 \
    libboost-python1.74.0 \
    gfal2 man && \
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
 /usr/local/gfal2-util/lib/python3.9/site-packages/gfal2_util \
 /usr/lib/python3.9/gfal2_util/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python3.9/site-packages/gfal2_util-1.8.0-py3.9.egg-info \
 /usr/lib/python3.9/
CMD /bin/bash
