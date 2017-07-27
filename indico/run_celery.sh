#!/bin/sh

. /opt/indico/.venv/bin/activate

export SQLAlchemyDatabaseURI="postgresql://$PGUSER:$PGPASSWORD@$PGHOST/$PGDATABASE"

echo 'Starting Celery...'
indico celery worker -B
