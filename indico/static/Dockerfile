FROM nginxinc/nginx-unprivileged:stable-alpine

USER root

RUN set -ex && \
        apk add --update py-pip unzip && \
        rm -rf /var/cache/apk/*

RUN chgrp -R 0 /var/cache/nginx

RUN set -ex && \
        mkdir /tmp/indico-pip && \
        pip install -U pip && \
        pip download --no-deps -d /tmp/indico-pip indico && \
        unzip /tmp/indico-pip/indico-*.whl -d /srv/ 'indico/htdocs/*' && \
        rm -rf /tmp/indico-pip

RUN rm /etc/nginx/conf.d/default.conf
COPY indico.conf /etc/nginx/conf.d/indico.conf

EXPOSE 8080
