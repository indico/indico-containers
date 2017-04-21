#/bin/sh

. /opt/indico/env/bin/activate

db_name=$1

psql -lqt | cut -d \| -f 1 | grep -qw $db_name

until [ $? -eq 0 ]; do
    sleep 1
    psql -lqt | cut -d \| -f 1 | grep -qw $db_name
done

psql -c 'SELECT * FROM events.events'

if [ $? -eq 1 ]; then
    echo 'Preparing DB...'
    echo 'CREATE EXTENSION unaccent;' | psql
    echo 'CREATE EXTENSION pg_trgm;' | psql
    indico db prepare
fi

echo 'Starting Indico...'
indico run -h 0.0.0.0 -u http://localhost:8000
