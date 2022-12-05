FROM bitnami/minideb:buster AS gfal-builder
RUN install_packages libboost-python-dev python3-setuptools \
    git wget cmake make gcc g++ ca-certificates \
    libglib2.0-dev libjson-c-dev doxygen libpugixml-dev \
    dcap-dev libxml2-dev libssl-dev libcurl4-openssl-dev \
    libglobus-gass-copy-dev libldap2-dev liblfc-dev libdpm-dev \
    libssh2-1-dev srm-ifce-dev libgtest-dev && \
    git clone https://github.com/cern-fts/davix.git && \
    cd davix && git submodule update --recursive --init && \
    mkdir build && cd build && \
    cmake .. && make && make install && cd ../.. && \
    wget http://deb.debian.org/debian/pool/main/x/xrootd/xrootd_5.0.3.orig.tar.gz && \
    tar xf xrootd_5.0.3.orig.tar.gz && \
    cd xrootd-5.0.3 && mkdir build && cd build && \
    cmake .. && make && make install && cd ../.. && \
    git clone https://github.com/cern-fts/gfal2.git && \
    cd gfal2 && mkdir build && cd build && \
    cmake -DLIBSSH2_INCLUDE_DIRS=/usr/local \
    -DDAVIX_PKG_FOUND=true -DDAVIX_COPY_PKG_FOUND=true \
    -DDAVIX_LIBRARIES=/usr/local/lib/libdavix.so .. && \
    make && make install && cd ../.. && \ 
    git clone https://github.com/cern-fts/gfal2-python.git && \
    cd gfal2-python && \
    mkdir build && cd build && \
    cmake -DGFAL2_PKG_FOUND=true \
    -DGFAL2_TRANSFER_PKG_FOUND=true \
    -DGFAL2_INCLUDE_DIRS=/usr/local/include/gfal2 \
    -DGFAL2_LIBRARIES="/usr/local/lib64/libgfal2.so;\
/usr/local/lib64/libgfal2.so.2;\
/usr/local/lib64/libgfal2.so.2.21.2;\
/usr/local/lib64/libgfal_transfer.so;\
/usr/local/lib64/libgfal_transfer.so.2;\
/usr/local/lib64/libgfal_transfer.so.2.21.2;\
/usr/local/lib64/gfal2-plugins/libgfal_plugin_dcap.so;\
/usr/local/lib64/gfal2-plugins/libgfal_plugin_gridftp.so;\
/usr/local/lib64/gfal2-plugins/libgfal_plugin_lfc.so;\
/usr/local/lib64/gfal2-plugins/libgfal_plugin_sftp.so;\
/usr/local/lib64/gfal2-plugins/libgfal_plugin_xrootd.so;\
/usr/local/lib64/gfal2-plugins/libgfal_plugin_file.so;\
/usr/local/lib64/gfal2-plugins/libgfal_plugin_http.so;\
/usr/local/lib64/gfal2-plugins/libgfal_plugin_rfio.so;\
/usr/local/lib64/gfal2-plugins/libgfal_plugin_srm.so" .. && \
    make && make install && cd ../.. && \
    mkdir /usr/local/gfal2-util && \
    git clone https://github.com/cern-fts/gfal2-util.git && \
    cd gfal2-util && python3 setup.py install --prefix=/usr/local/gfal2-util
 
FROM bitnami/minideb:buster AS oidc-builder
ENV BIN_PATH=/usr/local/oidc-agent
RUN install_packages \
    libcurl4-openssl-dev \
    libsodium-dev \
    libmicrohttpd-dev \
    libsecret-1-dev \
    libqrencode-dev \
    libwebkit2gtk-4.0-dev \
    git cmake make gcc g++ help2man ca-certificates && \
    git clone https://github.com/indigo-dc/oidc-agent && \
    cd oidc-agent && mkdir /usr/local/oidc-agent && \
    make && make install

FROM bitnami/minideb:buster
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib64/gfal2-plugins:/usr/local/lib:/usr/lib
RUN install_packages \
    libxml2 \
    libpugixml1v5 \
    libjson-c3 \
    libdcap1 \
    libglobus-gass-copy2 \
    liblfc1 \
    libdpm1 \
    libgfal-srm-ifce1 \
    libcurl4 \
    libmicrohttpd12 \
    libqrencode4 \
    libsodium23 \
    libsecret-1-0 \
    libboost-python1.67.0 \
    googletest \
    python3 \
    man && \
    ln -s /usr/bin/python3 /usr/bin/python
COPY --from=oidc-builder \
 /usr/local/oidc-agent/bin \
 /usr/local/bin/
COPY --from=gfal-builder \
 /usr/local/lib/libdavix.so.0.8.3 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libdavix.so.0 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libdavix.so \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/include/xrootd \
 /usr/local/include/xrootd/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdXml.so.3.0.0 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdXml.so.3 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdXml.so \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdUtils.so.3.0.0 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdUtils.so.3 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdUtils.so \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdCl.so.3.0.0 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdCl.so.3 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdCl.so \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdFfs.so.3.0.0 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdFfs.so.3 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdFfs.so \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdPosix.so.3.0.0 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdPosix.so.3 \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdPosix.so \
 /usr/local/lib/
COPY --from=gfal-builder \
 /usr/local/share/doc/gfal2 \
 /usr/local/share/doc/gfal2/
COPY --from=gfal-builder \
 /usr/local/etc/gfal2.d \
 /usr/local/etc/gfal2.d/
COPY --from=gfal-builder \
 /usr/local/share/man/man1/gfal2_version.1 \
 /usr/local/share/man/man1/
COPY --from=gfal-builder \
 /usr/local/include/gfal2 \
 /usr/local/include/gfal2/
COPY --from=gfal-builder \
 /usr/local/lib64 \
 /usr/local/lib64/
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
 /usr/local/gfal2-util/lib/python3.7/site-packages/gfal2_util \
 /usr/lib/python3.7/gfal2_util/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python3.7/site-packages/gfal2_util-1.8.0-py3.7.egg-info \
 /usr/lib/python3.7/
CMD /bin/bash
