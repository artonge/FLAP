# syntax = docker/dockerfile:experimental

FROM debian:buster-20200224-slim

COPY ./system/img_build/userpatches/overlay/install_flap.sh /install_flap.sh

# Make exported env var available during build on gitlab pipelines: https://docs.gitlab.com/ee/topics/autodevops/#custom-buildpacks
RUN --mount=type=secret,id=auto-devops-build-secrets . /run/secrets/auto-devops-build-secrets && /install_flap.sh $CI_COMMIT_REF_NAME

CMD ["flapctl", "start"]
