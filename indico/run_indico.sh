#!/bin/bash

. /opt/indico/.venv/bin/activate

export SQLAlchemyDatabaseURI="postgresql://$PGUSER:$PGPASSWORD@$PGHOST/$PGDATABASE"

psql -lqt | cut -d \| -f 1 | grep -qw $PGDATABASE

until [ $? -eq 0 ]; do
    sleep 1
    psql -lqt | cut -d \| -f 1 | grep -qw $PGDATABASE
done

psql -c 'SELECT * FROM events.events'

if [ $? -eq 1 ]; then
    echo 'Preparing DB...'
    echo 'CREATE EXTENSION unaccent;' | psql
    echo 'CREATE EXTENSION pg_trgm;' | psql
    indico db prepare
fi

rm -rf /opt/indico/static/*
cp -rL /opt/indico/htdocs /opt/indico/static/

echo 'Starting Indico...'
uwsgi /etc/uwsgi.ini
