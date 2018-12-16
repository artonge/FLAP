# Container
FROM python:2.7-stretch

EXPOSE 8000 8082

ENV SEAFILE_VERSION=6.3.4 \
    SEAFILE_SERVER=seafile-server

# ENV RELEASE_URL=https://github.com/haiwen/seafile-rpi/releases/download/v${SEAFILE_VERSION}/seafile-server_${SEAFILE_VERSION}_stable_pi.tar.gz
ENV RELEASE_URL=https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        mariadb-client && \
    pip install \
        Pillow==4.3.0 \
        setuptools \
        ldap \
        urllib3 \
        requests \
        mysql \
        python-memcached

# Create seafile user
RUN useradd -rms /bin/bash seafile
USER seafile
WORKDIR /home/seafile

# Download seafile
RUN curl -sSL -o - ${RELEASE_URL} | tar xzf - -C .

# Copy the startup script. It will:
#	1. Setup DB if necessary
#	2. Start seafile and seahub
COPY ./dockerfiles/seafile/start.sh ./start.sh

USER root
CMD ["./start.sh"]
