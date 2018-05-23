#!/bin/bash

. /opt/indico/.venv/bin/activate

psql $PGDATABASE -lqt | cut -d \| -f 1 | grep -qw $PGDATABASE

until [ $? -eq 0 ]; do
    sleep 1
    psql $PGDATABASE -lqt | cut -d \| -f 1 | grep -qw $PGDATABASE
done

psql -c 'SELECT * FROM events.events'

if [ $? -eq 1 ]; then
    echo 'Preparing DB...'
    if [ $USE_EXTERNAL_DB == 'y' ]; then
        echo 'Using external database...'
        echo 'CREATE EXTENSION unaccent;' | psql $PGDATABASE
        echo 'CREATE EXTENSION pg_trgm;' | psql $PGDATABASE
    else
        echo 'Using PostgreSQL container...'
        echo 'CREATE EXTENSION unaccent;' | psql -U postgres
        echo 'CREATE EXTENSION pg_trgm;' | psql -U postgres
    fi
    indico db prepare
fi

rm -rf /opt/indico/static/*
cp -rL /opt/indico/htdocs /opt/indico/static/

echo 'Starting Indico...'
uwsgi /etc/uwsgi.ini
