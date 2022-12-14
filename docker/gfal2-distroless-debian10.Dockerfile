FROM debian:buster-slim AS gfal-builder
RUN apt-get update && apt-get install -y libboost-python-dev \
    python3-setuptools git wget cmake make gcc g++ ca-certificates \
    libglib2.0-dev libjson-c-dev doxygen libpugixml-dev wget \
    dcap-dev libxml2-dev libssl-dev libcurl4-openssl-dev libgsoap-dev \
    libglobus-gass-copy-dev libldap2-dev liblfc-dev libdpm-dev \
    libssh2-1-dev srm-ifce-dev libgtest-dev gsoap && apt-get clean && \
    git clone https://github.com/cern-fts/davix.git && \
    cd davix && git submodule update --recursive --init && \
    mkdir build && cd build && cmake -Wno-dev -DENABLE_THIRD_PARTY_COPY=true .. && \
    make && make install && cd ../.. && \
    wget http://deb.debian.org/debian/pool/main/x/xrootd/xrootd_5.0.3.orig.tar.gz && \
    tar xf xrootd_5.0.3.orig.tar.gz && \
    cd xrootd-5.0.3 && mkdir build && cd build && \
    cmake .. && make && make install && cd ../.. && \
    git clone https://github.com/cern-fts/gfal2.git && \
    cd gfal2 && mkdir build && cd build && \
    cmake -DLIBSSH2_INCLUDE_DIRS=/usr/local .. && \
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

FROM gcr.io/distroless/python3-debian10
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib64/gfal2-plugins:$LD_LIBRARY_PATH
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_thread_pthread.so \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgsoapssl++-2.8.75.so \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libffi.so.6 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/liblzma.so.5 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libicudata.so.63 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libicuuc.so.63 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libicui18n.so.63 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/libgpg-error.so.0 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_proxy_ssl.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglobus_oldgaa.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgmp.so.10 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libhogweed.so.4 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libnettle.so.6 \
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
 /usr/lib/x86_64-linux-gnu/libcgsi_plugin.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgsoap-2.8.75.so \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libxml2.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/libgcrypt.so.20 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/liblcgdm.so.1 \
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
 /usr/lib/x86_64-linux-gnu/libltdl.so.7 \
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
 /usr/lib/x86_64-linux-gnu/libgnutls.so.30 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libsasl2.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgfal_srm_ifce.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libssh2.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/libuuid.so.1 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libdpm.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/liblfc.so.1 \
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
 /usr/lib/x86_64-linux-gnu/libdcap.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libjson-c.so.3 \
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
 /lib/x86_64-linux-gnu/libpcre.so.3 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libgthread-2.0.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libglib-2.0.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/lib/x86_64-linux-gnu/libboost_python37.so.1.67.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/libgcc_s.so.1 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/libexpat.so.1 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /lib/x86_64-linux-gnu/libz.so.1 \
 /lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/local/lib/libdavix.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/local/lib/libdavix_copy.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdXml.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdUtils.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdCl.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdFfs.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/local/lib/libXrdPosix.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=gfal-builder \
 /usr/local/etc/gfal2.d \
 /usr/local/etc/gfal2.d/
COPY --from=gfal-builder \
 /usr/local/lib64/gfal2-plugins \
 /usr/local/lib64/gfal2-plugins/ 
COPY --from=gfal-builder \
 /usr/local/lib64 \
 /usr/local/lib64/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/bin \
 /usr/local/bin/
COPY --from=gfal-builder \
 /usr/lib/python3/dist-packages/gfal2.so \
 /usr/lib/python3/dist-packages/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python3.7/site-packages/gfal2_util \
 /usr/lib/python3.7/gfal2_util/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python3.7/site-packages/gfal2_util-1.8.0-py3.7.egg-info \
 /usr/lib/python3.7/
COPY --from=gfal-builder \
 /bin/sh /bin
ENTRYPOINT ["/bin/sh"]