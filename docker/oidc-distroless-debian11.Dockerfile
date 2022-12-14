FROM debian:bullseye-slim AS oidc-builder
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

FROM gcr.io/distroless/base-debian11
COPY --from=oidc-builder \
 /lib/x86_64-linux-gnu/libpcre.so.3 \
 /lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libblkid.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /lib/x86_64-linux-gnu/libkeyutils.so.1 \
 /lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /lib/x86_64-linux-gnu/libgpg-error.so.0 \
 /lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libffi.so.7 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /lib/x86_64-linux-gnu/libselinux.so.1 \
 /lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libmount.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libtasn1.so.6 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libp11-kit.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libsasl2.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libkrb5support.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /lib/x86_64-linux-gnu/libcom_err.so.2 \
 /lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libk5crypto.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libkrb5.so.3 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libgmp.so.10 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libnettle.so.8 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libhogweed.so.6 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libunistring.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libpcre2-8.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libgcrypt.so.20 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libgnutls.so.30 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /lib/x86_64-linux-gnu/libz.so.1 \
 /lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libzstd.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libpsl.so.5 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libssh2.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/librtmp.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libidn2.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libnghttp2.so.14 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libglib-2.0.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libcjson.so.1 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libcurl.so.4 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libqrencode.so.4 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libsodium.so.23 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libsecret-1.so.0 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/libmicrohttpd.so.12 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/local/oidc-agent/bin \
 /usr/bin
COPY --from=oidc-builder \
 /bin/sh \
 /bin
CMD ["/bin/sh"]
