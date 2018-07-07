#!/bin/bash

. /opt/indico/.venv/bin/activate

echo 'Starting Celery...'
indico celery worker -B
