FROM node:10.15.0-stretch-slim as build

EXPOSE 80

WORKDIR /flap

# Build dependencies
RUN apt update
RUN apt install -y python
RUN apt install -y build-essential

COPY ./package*.json ./
RUN npm install --only=production

# Runtime dependencies
RUN apt install -y argon2

COPY ./build ./build

CMD ["npm", "start"]
