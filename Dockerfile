# syntax = docker/dockerfile:experimental

FROM debian:10.4-slim

COPY ./system/img_build/userpatches/overlay/install_flap.sh /install_flap.sh

# Make exported env var available during build on gitlab pipelines: https://docs.gitlab.com/ee/topics/autodevops/#custom-buildpacks
RUN --mount=type=secret,id=auto-devops-build-secrets . /run/secrets/auto-devops-build-secrets && /install_flap.sh $CI_COMMIT_REF_NAME

WORKDIR /opt/flap

CMD ["flapctl", "start"]
