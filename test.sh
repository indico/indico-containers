#!/bin/bash

DIR="indico-${1:-prod}"
URL=http://localhost:8080/category/0/statistics
TIMEOUT=120

check_indico_status() {
    response=$(curl -L --write-out '%{http_code}' --silent --output /dev/null $URL)
    [[ $response = "200" ]]
}

cd $DIR
# make sure the cluster is down
docker compose down
# then try to bring it up
docker compose up &

start_time="$(date -u +%s)"
until check_indico_status; do
    echo "Waiting for Indico to become available..."
    sleep 10

    curr_time="$(date -u +%s)"
    if ((($curr_time - $start_time) > TIMEOUT)); then
        break
    fi
done

# Print response from server, for clarity
echo "Response from Indico:"
curl -fsSL $URL | jq .
echo ""

# yay!
echo "Indico seems alive!"

echo "Shutting down..."
docker compose down

exit 0
