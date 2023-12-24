FROM registry.access.redhat.com/ubi9/ubi-minimal AS oidc-builder
ENV BIN_PATH=/usr/local/oidc-agent
RUN \
    rpm -ivh http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-9.0-18.el9.noarch.rpm && \
    rpm -ivh http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-9.0-18.el9.noarch.rpm && \
    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    microdnf --enablerepo=crb install -y \
    libcurl-devel \
    libsodium-devel \
    libmicrohttpd-devel \
    libsecret-devel \
    qrencode-devel \
    webkitgtk4-devel \
    git gcc gcc-c++ \
    make bash-completion \
    findutils help2man && \
    git clone https://github.com/indigo-dc/oidc-agent && \
    cd oidc-agent && mkdir /usr/local/oidc-agent && \
    make && make install

FROM registry.access.redhat.com/ubi9/ubi-minimal AS gfal-builder
COPY ./assets/conf/dmc-el9.repo /etc/yum.repos.d/
RUN \
    rpm -ivh http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-9.0-18.el9.noarch.rpm && \
    rpm -ivh http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-9.0-18.el9.noarch.rpm && \
    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    microdnf --enablerepo=crb install -y \
    gfal2 gfal2-devel \
    python3-setuptools \
    python3-devel \
    boost-python3-devel \
    git gcc gcc-c++ \
    make bash-completion \
    findutils help2man \
    cmake doxygen && \
    git clone https://github.com/cern-fts/gfal2-python.git && \
    cd gfal2-python && mkdir build && cd build && \
    cmake .. && make && make install && \
    cd ../.. && mkdir /usr/local/gfal2-util && \
    git clone https://github.com/cern-fts/gfal2-util.git && \
    cd gfal2-util && python3 setup.py install --prefix=/usr/local/gfal2-util
 
FROM registry.access.redhat.com/ubi9/ubi-minimal
ENV PATH=/usr/local/oidc-agent/bin:$PATH
COPY ./assets/conf/dmc-el9.repo /etc/yum.repos.d/
RUN \
    rpm -ivh http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-9.0-18.el9.noarch.rpm && \
    rpm -ivh http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-9.0-18.el9.noarch.rpm && \
    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    microdnf install -y \
    libmicrohttpd \
    qrencode \
    libsodium \
    libsecret \
    python3 \
    boost-python3 \
    gfal2-all \
    man jq && \
    microdnf clean all
COPY --from=oidc-builder \
 /usr/lib/x86_64-linux-gnu/liboidc-agent.so.4 \
 /usr/lib/x86_64-linux-gnu/
COPY --from=oidc-builder \
 /usr/local/oidc-agent \
 /usr/local/oidc-agent/
COPY --from=gfal-builder \
 /usr/lib64/python3.9/site-packages/gfal2.so \
 /usr/lib64/python3.9/site-packages/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/bin \
 /usr/local/bin/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/share/man/man1 \
 /usr/local/share/man/man1/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python3.9/site-packages/gfal2_util \
 /usr/local/lib/python3.9/site-packages/gfal2_util/
COPY --from=gfal-builder \
 /usr/local/gfal2-util/lib/python3.9/site-packages/gfal2_util-1.8.0-py3.9.egg-info \
 /usr/local/lib/python3.9/site-packages/
CMD /bin/bash
