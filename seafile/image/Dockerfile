# We need some python stuff so the python image is the best for us
FROM python:2.7-slim-stretch

EXPOSE 8000 8082 8080

ENV SEAFILE_VERSION=6.3.4

# Downloads URLs
ENV RELEASE_URL_ARMHF=https://github.com/haiwen/seafile-rpi/releases/download/v${SEAFILE_VERSION}/seafile-server_${SEAFILE_VERSION}_stable_pi.tar.gz
ENV RELEASE_URL_AMD64=https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

WORKDIR /root

# Copy the patch for SSO support
COPY ./sso.patch /sso.patch

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libldap2-dev \
        libmariadbclient-dev \
        libmemcached-dev \
        mariadb-client \
        patch \
        python-mysqldb \
# pgrep is needed during `seafile.sh start`
        procps \
# gcc is needed to build some python dependencies
        gcc \
# curl is needed to fetch seafile
        curl && \
    pip install \
        django-pylibmc \
        mysql \
        Pillow==4.3.0 \
        pylibmc \
        python-ldap \
        python-memcached \
        requests \
        setuptools \
        urllib3 && \
# Download seafile
    dpkg --print-architecture && \
    case "$(dpkg --print-architecture)" in \
        "amd64") curl -sSL -o - ${RELEASE_URL_AMD64} | tar xzf - -C . ;; \
        "armhf") curl -sSL -o - ${RELEASE_URL_ARMHF} | tar xzf - -C . ;; \
        *) echo "Unknown architecture" && exit 1 ;; \
    esac && \
# Reduce final image size
    apt-get remove -y \
          curl \
          gcc \
          libmariadbclient-dev \
          libmemcached-dev && \
      apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
# Apply patch for SSO
# Credit: https://github.com/YunoHost-Apps/seafile_ynh/commit/40ec2d416c39b2aca3936f6ae4e7f4573bc6535d#diff-dc2801cb46a5d60e62234cff98084498
    cd ./seafile-server-${SEAFILE_VERSION}/seahub && \
    patch -p1 < /sso.patch

# Copy the startup script. It will:
#	1. Setup DB if necessary
#	2. Start seafile and seahub
COPY ./start.sh /start.sh

WORKDIR /shared

CMD ["/start.sh"]
