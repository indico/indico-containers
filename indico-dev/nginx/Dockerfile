FROM nginxinc/nginx-unprivileged:stable-alpine

USER root

RUN set -ex && \
        apk add --update py-pip unzip && \
        rm -rf /var/cache/apk/*

RUN rm /etc/nginx/conf.d/default.conf

EXPOSE 8080

# OpenShift runs containers using an arbitrarily assigned user ID for security reasons
# This user is always in the root group so it is needed to grant privileges to group 0.
RUN chgrp -R 0 /var/* /etc/nginx && chmod -R g+rwX /var/* /etc/nginx

COPY run_nginx.sh indico.conf.template /
RUN chmod +x /run_nginx.sh

ENTRYPOINT ["/run_nginx.sh"]
