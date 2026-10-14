#!/bin/bash

. /opt/indico/.venv/bin/activate

check_db_ready() {
    psql -c 'SELECT COUNT(*) FROM events.events'
}

# Wait until the DB becomes ready
check_db_ready
until [ $? -eq 0 ]; do
    echo "Waiting for DB to be ready..."
    sleep 10
    check_db_ready
done

echo 'Starting Celery...'
indico celery worker -B
