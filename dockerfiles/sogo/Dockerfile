FROM debian:9.6-slim

EXPOSE 20000

ENV SOGO_VERSION 4.0.4
ENV SOPE_DL_URL https://github.com/inverse-inc/sope/archive/SOPE-$SOGO_VERSION.tar.gz
ENV SOGO_DL_URL https://github.com/inverse-inc/sogo/archive/SOGo-$SOGO_VERSION.tar.gz

# Install build and runtime dependencies
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        gobjc \
        gnustep-base-common \
        gnustep-make \
        libcurl3            libcurl4-openssl-dev \
        libgnustep-base1.24 libgnustep-base-dev \
        libldap-2.4-2       libldap2-dev \
        libmemcached11      libmemcached-dev \
        libmariadbclient18  libmariadbclient-dev-compat \
        libpq5              libpq-dev \
        libssl1.1           libssl-dev \
        libwbxml2-0         libwbxml2-dev \
        libxml2             libxml2-dev && \
# Install SOPE
    mkdir /tmp/sope && \
    curl -SLf $SOPE_DL_URL | tar -zx --strip-components 1 -f - -C /tmp/sope && \
    cd /tmp/sope && \
    ./configure --with-gnustep && \
    make && \
    make install && \
# Install SOGo
    mkdir /tmp/sogo && \
    curl -SLf $SOGO_DL_URL | tar -zx --strip-components 1 -f - -C /tmp/sogo && \
    cd /tmp/sogo && \
    ./configure && \
    make && \
    make install && \
# Create sogo user
    useradd -ms /bin/bash sogo && \
    mkdir /var/run/sogo && chown sogo:sogo /var/run/sogo && \
# Clean image
    apt-get remove -y \
        build-essential \
        curl \
        gobjc \
        libcurl4-openssl-dev \
        libgnustep-base-dev \
        libldap2-dev \
        libmemcached-dev \
        libpq-dev \
        libssl-dev \
        libwbxml2-dev \
        libxml2-dev && \
    apt-get install -y mariadb-client && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER sogo

ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib/sogo

COPY ./start.sh ./start.sh

CMD ["./start.sh"]
