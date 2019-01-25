# Inspried by https://github.com/dinkel/docker-openldap
FROM debian:9.6-slim

# Prevent apt from asking information during ldap installation
ENV DEBIAN_FRONTEND noninteractive

ENV OPENLDAP_VERSION 2.4.44

RUN apt-get update && \
# Install slapd
    apt-get install --no-install-recommends -y slapd=${OPENLDAP_VERSION}* && \
# Move the ldap conf to avoid overiding it on first run
# It will be moved back on the first run (in start.sh)
    mv /etc/ldap /etc/ldap.bak && \
# Reduce final image size
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./image/start.sh /start.sh

CMD ["./start.sh"]
