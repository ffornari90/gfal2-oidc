FROM debian:bullseye-slim AS gfal-builder
RUN apt-get update && apt-get install -y python-setuptools python-dev cmake \
    git wget make ca-certificates gfal2 libgfal2-dev gcc g++ && \
    wget https://boostorg.jfrog.io/artifactory/main/release/1.67.0/source/boost_1_67_0.tar.gz && \
    tar xf boost_1_67_0.tar.gz && cd boost_1_67_0 && \
    ./bootstrap.sh --with-python=/usr/bin/python && \
    ./b2 install --with-python && cd .. && \
    git clone https://github.com/cern-fts/gfal2-python.git && \
    cd gfal2-python && git checkout tags/v1.10.0 && \
    sed -i '24s/.*/                string(REGEX REPLACE ".*version (.*)\\n" "\\\\1" "${EPYDOC_VERSION}" "${EPYDOC_VERSION_UNPARSED}")/' \
    cmake/modules/MacroAddepydoc.cmake && \
    sed -i '32s/.*/        IF("${EPYDOC_VERSION}" VERSION_GREATER  "3.0.0")/' \
    cmake/modules/MacroAddepydoc.cmake && \
    mkdir build && cd build && cmake -Wno-dev .. && \
    make && make install && cd ../.. && mkdir /usr/local/gfal2-util && \
    git clone https://github.com/cern-fts/gfal2-util.git && \
    cd gfal2-util && git checkout tags/v1.6.0 && \
    python2.7 setup.py install --prefix=/usr/local/gfal2-util

FROM gcr.io/distroless/base-debian11
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/liblzma.so.5 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/libgpg-error.so.0 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libssh2.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgcrypt.so.20 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/liblz4.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libzstd.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libsystemd.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libtinyxml.so.2.6.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libicudata.so.67 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libicuuc.so.67 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgsoapssl++-2.8.104.so \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libuuid.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libxml2.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libffi.so.7 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/libgcc_s.so.1 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/libz.so.1 \
 /lib/x86_64-linux-gnu/
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
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libpython2.7.so.1.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/local/lib/libboost_python27.so.1.67.0 \
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
 /usr/lib/x86_64-linux-gnu/libdcap.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libdavix.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libdavix_copy.so.0 \
 /usr/lib/x86_64-linux-gnu/

COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libXrdXml.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libXrdUtils.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libXrdCl.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libXrdPosix.so.3 \
 /usr/lib/x86_64-linux-gnu/

COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libltdl.so.7 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libcgsi_plugin.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_gssapi_gsi.so.4 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_gss_assist.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_common.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_gass_copy.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_ftp_control.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_ftp_client.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_gass_transfer.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_gssapi_error.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_io.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_xio.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_gsi_sysconfig.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_gsi_credential.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_gsi_callback.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_gsi_proxy_core.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_openssl_error.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_openssl.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_callout.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_gsi_cert_utils.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_proxy_ssl.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_oldgaa.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_thread_pthread.so \
 /usr/lib/x86_64-linux-gnu/

COPY --from=gfal-builder \
 /usr/local/gfal2-util/bin \
 /usr/local/bin/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/gfal2-plugins \
 /usr/lib/x86_64-linux-gnu/gfal2-plugins/
COPY --from=gfal-builder \
 /etc/gfal2.d \
 /etc/gfal2.d/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python2.7/site-packages/gfal2_util \
 /usr/lib/python2.7/gfal2_util/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python2.7/site-packages/gfal2_util-1.6.0-py2.7.egg-info \
 /usr/lib/python2.7/
COPY --from=gfal-builder \
 /bin/ls /bin
COPY --from=gfal-builder \
 /bin/sh /bin
COPY --from=gfal-builder \
 /usr/lib/python2.7 \
 /usr/lib/python2.7/
COPY --from=gfal-builder \
 /usr/bin/python2.7 /usr/bin/python
ENTRYPOINT ["/bin/sh"]
