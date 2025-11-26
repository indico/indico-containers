#!/bin/sh

envsubst '\$NGINX_SERVER_NAME' < /indico.conf.template > /etc/nginx/conf.d/indico.conf
nginx -g "daemon off;"
