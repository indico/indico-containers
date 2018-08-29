FROM nginxinc/nginx-unprivileged:stable-alpine

USER root

RUN set -ex && \
        apk add --update py-pip unzip && \
        rm -rf /var/cache/apk/*

RUN rm /etc/nginx/conf.d/default.conf

COPY indico.conf.template /tmp

EXPOSE 8080

# OpenShift runs containers using an arbitrarily assigned user ID for security reasons
# This user is always in the root group so it is needed to grant privileges to group 0.
RUN chgrp -R 0 /var/* /etc/nginx && chmod -R g+rwX /var/* /etc/nginx

COPY run.sh /
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
