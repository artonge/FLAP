# BUILD STAGE
FROM node:10.15.0-stretch-slim as builder
WORKDIR /manager
COPY ./ ./
# Build dependencies
# RUN apt-get update
# RUN apt-get install -y build-essential python
RUN npm install
# Build
RUN npm run build
# Reinstall node_module but with --only=production flag to not install all dependencies
# The generated node_modules will be used in the runtime stage
RUN rm -rf ./node_modules
RUN npm install --only=production

# RUNTIME STAGE
FROM node:10.15.0-stretch-slim
WORKDIR /manager
COPY --from=builder /manager/build ./build
COPY --from=builder /manager/package.json ./package.json
COPY --from=builder /manager/node_modules ./node_modules
# RUN apt-get update && \
# Runtime dependencies
# apt-get install -y whois && \
# Reduce final image size
# apt-get autoremove -y && \
# rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD ["npm", "start"]
