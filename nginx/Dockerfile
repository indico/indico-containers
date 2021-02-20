FROM nginxinc/nginx-unprivileged:stable-alpine

USER root

RUN set -ex && \
        apk add --update py-pip unzip && \
        rm -rf /var/cache/apk/*

RUN rm /etc/nginx/conf.d/default.conf

ARG CERT_BASENAME
ENV SERVICE_HTTP_PORT=80 SERVICE_HTTPS_PORT=443

COPY indico.conf.template /tmp
COPY secrets/$CERT_BASENAME.crt /opt/secrets/
COPY secrets/$CERT_BASENAME.key /opt/secrets/

EXPOSE $SERVICE_HTTP_PORT $SERVICE_HTTPS_PORT

# OpenShift runs containers using an arbitrarily assigned user ID for security reasons
# This user is always in the root group so it is needed to grant privileges to group 0.
RUN chgrp -R 0 /var/* /etc/nginx && chmod -R g+rwX /var/* /etc/nginx

COPY run.sh /
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
