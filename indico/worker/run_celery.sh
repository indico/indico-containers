#!/bin/bash

/opt/indico/set_user.sh
. /opt/indico/.venv/bin/activate

echo 'Waiting for indico-web to be online...'
while [[ "$(curl -L --max-time 10 -s -o /dev/null -w ''%{http_code}'' 'http://indico-web:59999')" != "200" ]]; do
    sleep 10;
    echo 'Waiting...'
done

echo 'Starting Celery...'
indico celery worker -B
