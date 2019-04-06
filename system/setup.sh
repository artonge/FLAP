#!/bin/bash

# Create .env files in each services
for s in $(ls)
do
    if [ -f ${s}/${s}.template.env ]
    then
        cp ${s}/${s}.template.env ${s}/${s}.env
    fi
done

# Start the manager a wait for it to return
docker-compose run manager port --open 443
docker-compose run manager config --generate
docker-compose run manager tls

# Start all services
docker-compose up -d
