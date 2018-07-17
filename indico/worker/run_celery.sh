#!/bin/bash

. /opt/indico/set_user.sh
. /opt/indico/.venv/bin/activate

echo 'Starting Celery...'
indico celery worker -B
