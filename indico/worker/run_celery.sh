#!/bin/bash

/opt/indico/set_user.sh
. /opt/indico/.venv/bin/activate

# Wait for Indico to setup the DB
echo 'Waiting for indico-web to be online...'
BASE_URL="${SERVICE_HOSTNAME}:${SERVICE_PORT}"
while [[ $(curl -L --max-time 10 -s -o /dev/null --header "Host: ${BASE_URL}" -w ''%{http_code}'' 'http://indico-web:59999') != "200" ]]; do
    sleep 10;
    echo 'Waiting for indico-web to be online...'
done

echo 'Starting Celery...'
indico celery worker -B
