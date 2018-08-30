#!/bin/sh

LATEST_VERSION=$(curl --insecure https://api.github.com/repos/indico/indico/releases/latest | jq '.name[1:]' --raw-output)
echo Building Indico ${LATEST_VERSION}...
docker build indico/worker -t getindico/indico:latest -t getindico/indico:$LATEST_VERSION --build-arg tag=${LATEST_VERSION}
