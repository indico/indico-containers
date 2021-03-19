#! /bin/sh

# set the nginx host/port to the service's hostname
envsubst '\$SERVICE_HOSTNAME \$SERVICE_HTTP_PORT \$SERVICE_HTTPS_PORT' < /tmp/indico.conf.template > /etc/nginx/conf.d/indico.conf

if [ -z "${ISSUE_LETSENCRYPT+x}" ] || [ "$ISSUE_LETSENCRYPT" != "" ]
then
    nginx
    sleep 1 # wait for nginx to start

    # use --test flag for debugging
    ${ACME_DIR}/acme.sh --issue --nginx -d $SERVICE_HOSTNAME

    ${ACME_DIR}/acme.sh --install-cert -d $SERVICE_HOSTNAME \
	       --key-file       /opt/secrets/mycert.key \
	       --fullchain-file /opt/secrets/mycert.crt \
	       --reloadcmd 'nginx -s reload'

    nginx -s quit
    sleep 1 # wait for nginx to stop
fi

nginx -g "daemon off;"
