#!/bin/bash

# cp indico-web.env.sample indico-web.env
# sed ...

URL=https://localhost:443/category/0/statistics
TIMEOUT=120

# make sure the cluster is down
docker-compose down
# then try to bring it up
docker-compose up -d

timeout_handler() {
    # SIGALRM caught, let's just exit
    exit 1
}

trap timeout_handler ALRM

# this is the timer process that will send SIGALRM
pid=$$
(
    sleep $TIMEOUT
    echo 'Timeout! Killing process'
    kill -s ALRM $pid
) &
alarm=$!

while [[ "$(curl -k -L --max-time 10 -s -o /dev/null -w ''%{http_code}'' $URL)" != "200" ]]; do
    sleep 30;
    echo 'Waiting...'
done

# Print response from server, for clarity
curl -L $URL

# yay!
echo 'Indico seems alive!'

# remove timer
kill -s TERM $alarm > /dev/null 2>&1

docker-compose down

exit 0
