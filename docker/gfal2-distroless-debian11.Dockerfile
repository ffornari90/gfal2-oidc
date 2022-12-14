FROM python:3.9-bullseye AS gfal-builder
RUN apt-get update && apt-get install -y python-setuptools python-dev cmake \
    git wget make ca-certificates gfal2 libgfal2-dev libc6-dev libmpc3 libmpfr6 \
    libgomp1 libitm1 libatomic1 libasan5 liblsan0 libtsan0 libubsan1 libquadmath0 && apt-get clean && \
    wget http://security.ubuntu.com/ubuntu/pool/universe/g/gcc-8/g++-8_8.4.0-3ubuntu2_amd64.deb && \
    wget http://security.ubuntu.com/ubuntu/pool/universe/g/gcc-8/gcc-8-base_8.4.0-3ubuntu2_amd64.deb && \
    wget http://security.ubuntu.com/ubuntu/pool/universe/g/gcc-8/gcc-8_8.4.0-3ubuntu2_amd64.deb && \
    wget http://security.ubuntu.com/ubuntu/pool/universe/g/gcc-8/libstdc++-8-dev_8.4.0-3ubuntu2_amd64.deb && \
    wget http://security.ubuntu.com/ubuntu/pool/universe/g/gcc-8/libgcc-8-dev_8.4.0-3ubuntu2_amd64.deb && \
    wget http://security.ubuntu.com/ubuntu/pool/universe/g/gcc-8/libmpx2_8.4.0-3ubuntu2_amd64.deb && \
    wget http://security.ubuntu.com/ubuntu/pool/universe/g/gcc-8/cpp-8_8.4.0-3ubuntu2_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/main/i/isl/libisl22_0.22.1-1_amd64.deb && \
    dpkg -i libisl22_0.22.1-1_amd64.deb && dpkg -i gcc-8-base_8.4.0-3ubuntu2_amd64.deb && \
    dpkg -i libmpx2_8.4.0-3ubuntu2_amd64.deb && dpkg -i libgcc-8-dev_8.4.0-3ubuntu2_amd64.deb && \
    dpkg -i libstdc++-8-dev_8.4.0-3ubuntu2_amd64.deb && dpkg -i cpp-8_8.4.0-3ubuntu2_amd64.deb && \
    dpkg -i gcc-8_8.4.0-3ubuntu2_amd64.deb && dpkg -i g++-8_8.4.0-3ubuntu2_amd64.deb && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 110 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 110 && \
    update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-8 110 && \
    update-alternatives --install /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-8 110 && \
    update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-8 110 && \
    update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-8 110 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-8 110 && \
    wget https://boostorg.jfrog.io/artifactory/main/release/1.67.0/source/boost_1_67_0.tar.gz && \
    tar xf boost_1_67_0.tar.gz && cd boost_1_67_0 && \
    ./bootstrap.sh --with-python=/usr/bin/python && \
    ./b2 install --with-python && \
    ./bootstrap.sh --with-python=/usr/bin/python3.9 && \
    ./b2 install --with-python && cd .. && \
    git clone https://github.com/cern-fts/gfal2-python.git && \
    cd gfal2-python && \
    git checkout tags/v1.10.1 && \
    sed -i '24s/.*/                string(REGEX REPLACE ".*version (.*)\\n" "\\\\1" "${EPYDOC_VERSION}" "${EPYDOC_VERSION_UNPARSED}")/' \
    cmake/modules/MacroAddepydoc.cmake && \
    sed -i '32s/.*/        IF("${EPYDOC_VERSION}" VERSION_GREATER  "3.0.0")/' \
    cmake/modules/MacroAddepydoc.cmake && \
    mkdir build && cd build && cmake -Wno-dev .. && \
    make && make install && cd ../.. && mkdir /usr/local/gfal2-util && \
    git clone https://github.com/cern-fts/gfal2-util.git && \
    cd gfal2-util && python3 setup.py install --prefix=/usr/local/gfal2-util

FROM gcr.io/distroless/python3-debian11
#ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/libselinux.so.1 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/libpcre.so.3 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libpcre2-8.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgmp.so.10 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libhogweed.so.6 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libnettle.so.8 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libtasn1.so.6 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libunistring.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libidn2.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libp11-kit.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgnutls.so.30 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libsasl2.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libjson-c.so.5 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libpugixml.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgthread-2.0.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglib-2.0.so.0 \
 /usr/lib/x86_64-linux-gnu/
#COPY --from=gfal-builder \
# /usr/local/lib \
# /usr/local/lib/
#COPY --from=gfal-builder \
# /usr/local/lib/libboost_python39.a \
# /usr/lib/x86_64-linux-gnu/
#COPY --from=gfal-builder \
# /usr/local/lib/libpython3.9.so.1.0 \
# /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/local/lib/libboost_python39.so.1.67.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgfal2.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgfal_transfer.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgfal_srm_ifce.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/bin \
 /usr/local/bin/
COPY --from=gfal-builder \
 /usr/local/lib/python3.9/site-packages/gfal2.so \
 /usr/lib/python3.9/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python3.9/site-packages/gfal2_util \
 /usr/lib/python3.9/gfal2_util/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python3.9/site-packages/gfal2_util-1.8.0-py3.9.egg-info \
 /usr/lib/python3.9/
COPY --from=gfal-builder \
 /bin/ls /bin
COPY --from=gfal-builder \
 /bin/sh /bin
COPY --from=gfal-builder \
 /usr/bin/python3 /usr/bin/python
ENTRYPOINT ["/bin/sh"]
