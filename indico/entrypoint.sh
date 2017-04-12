#/bin/sh

. /opt/indico/env/bin/activate

psql -c 'SELECT * FROM events.events'

if [ $? -eq 1 ]; then
    echo 'Preparing DB...'
    echo 'CREATE EXTENSION unaccent;' | psql
    echo 'CREATE EXTENSION pg_trgm;' | psql
    indico db prepare
fi

echo 'Starting Indico...'
indico run -h 0.0.0.0 -u http://localhost:8000
