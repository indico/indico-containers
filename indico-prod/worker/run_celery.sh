#!/bin/bash

check_db_ready() {
    psql -c 'SELECT COUNT(*) FROM events.events'
}

# Wait until the DB becomes ready
check_db_ready
until [ $? -eq 0 ]; do
    echo "Waiting for DB to be ready..."
    sleep 10
    check_db_ready
done

# Check if latex is used and pull container image
if cat /opt/indico/etc/indico.conf | grep XELATEX_PATH | grep podman && [ "${1:-worker}" == "worker" ]; then
    echo 'LaTeX using podman is enabled, pulling container image'
    indico maint pull-latex-image
else
    echo 'No need to pull container image'
fi

echo 'Starting Celery...'
indico celery ${1:-worker}
