#!/bin/bash

. /opt/indico/.venv/bin/activate

export SQLALCHEMY_DATABASE_URI="postgresql://$PGUSER:$PGPASSWORD@$PGHOST/$PGDATABASE"

echo 'Starting Celery...'
indico celery worker -B
