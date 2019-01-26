FROM node:10.15.0-stretch-slim

EXPOSE 80

WORKDIR /flap

COPY ./package*.json ./
COPY ./build ./build

RUN apt-get update && \
    apt-get install -y \
# Build dependencies
        build-essential \
        python \
# Runtime dependencies
        whois && \
    npm install --only=production && \
# Reduce final image size
    apt-get remove -y \
        python \
        build-essential && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["npm", "start"]
