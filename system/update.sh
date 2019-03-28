#!/bin/bash

git pull
git submodule update

docker-compose down
docker-compose up
