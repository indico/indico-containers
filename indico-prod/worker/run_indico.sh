#!/bin/bash

/opt/indico/set_user.sh
. /opt/indico/.venv/bin/activate

connect_to_db() {
    psql -lqt | cut -d \| -f 1 | grep -qw $PGDATABASE
}

# Wait until the DB becomes available
until connect_to_db; do
    echo "Waiting for DB to become available..."
    sleep 1
done

# Check whether the DB is already setup
psql -c 'SELECT COUNT(*) FROM events.events'

if [ $? -eq 1 ]; then
    echo 'Preparing DB...'
    echo 'CREATE EXTENSION unaccent;' | psql
    echo 'CREATE EXTENSION pg_trgm;' | psql
    indico db prepare
fi

echo 'Starting Indico...'
uwsgi /etc/uwsgi.ini
