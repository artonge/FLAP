# We need some python stuff so the python image is the best for us
FROM python:2.7-slim-stretch

ENV SEAFILE_VERSION=6.3.4
ENV RELEASE_URL_ARMHF=https://github.com/haiwen/seafile-rpi/releases/download/v${SEAFILE_VERSION}/seafile-server_${SEAFILE_VERSION}_stable_pi.tar.gz
ENV RELEASE_URL_AMD64=https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

WORKDIR /root

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python-mysqldb \
        mariadb-client \
        libmariadbclient-dev \
# pgrep is needed during `seafile.sh start`
        procps \
# gcc is needed to build some python dependencies
        gcc \
# curl is needed to fetch seafile
        curl && \
    pip install \
        Pillow==4.3.0 \
        setuptools \
        ldap \
        urllib3 \
        requests \
        mysql \
        python-memcached
# Download seafile
RUN dpkg --print-architecture && \
    case "$(dpkg --print-architecture)" in \
        "amd64") curl -sSL -o - ${RELEASE_URL_AMD64} | tar xzf - -C . ;; \
        "armhf") curl -sSL -o - ${RELEASE_URL_ARMHF} | tar xzf - -C . ;; \
        *) echo "Unknown architecture" && exit 1 ;; \
    esac
# Reduce final image size
RUN apt-get remove -y \
        curl \
        gcc \
        libmariadbclient-dev && \
    apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the startup script. It will:
#	1. Setup DB if necessary
#	2. Start seafile and seahub
COPY ./start.sh ./start.sh

EXPOSE 443 8082

CMD ["./start.sh"]
