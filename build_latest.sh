#!/bin/sh
# Builds the latest production Indico image

if ! command -v jq >/dev/null 2>&1
then
    echo 'jq is not installed'
    exit
fi

LATEST_VERSION=$(curl --insecure https://api.github.com/repos/indico/indico/releases/latest | jq '.name[1:]' --raw-output)
echo "Building Indico ${LATEST_VERSION}..."
docker build indico-prod/worker -t getindico/indico:latest -t getindico/indico:$LATEST_VERSION --build-arg tag=${LATEST_VERSION}
