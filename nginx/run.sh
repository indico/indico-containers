#! /bin/sh

# set the nginx host/port to the service's hostname
envsubst '\$SERVICE_HOSTNAME \$SERVICE_PORT' < /tmp/indico.conf.template > /etc/nginx/conf.d/indico.conf

nginx -g "daemon off;"
