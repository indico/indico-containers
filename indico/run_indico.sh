#!/bin/bash

. /opt/indico/.venv/bin/activate

export SQLALCHEMY_DATABASE_URI="postgresql://$PGUSER:$PGPASSWORD@$PGHOST/$PGDATABASE"
echo $PGUSER
echo $PGDATABASE
echo $SQLALCHEMY_DATABASE_URI

psql -lqt | cut -d \| -f 1 | grep -qw $PGDATABASE

until [ $? -eq 0 ]; do
    sleep 1
    psql -lqt | cut -d \| -f 1 | grep -qw $PGDATABASE
done

psql -c 'SELECT * FROM events.events'

if [ $? -eq 1 ]; then
    echo 'Preparing DB...'
    echo 'CREATE EXTENSION unaccent;' | psql -U postgres
    echo 'CREATE EXTENSION pg_trgm;' | psql -U postgres
    indico db prepare
fi

rm -rf /opt/indico/static/*
cp -rL /opt/indico/htdocs /opt/indico/static/

echo 'Starting Indico...'
uwsgi /etc/uwsgi.ini
