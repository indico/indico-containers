FROM nginxinc/nginx-unprivileged:stable-alpine

USER root

RUN set -ex && \
        apk add --update py-pip unzip && \
        rm -rf /var/cache/apk/*

RUN set -ex && \
        mkdir /tmp/indico-pip && \
        pip install -U pip && \
        pip download --no-deps -d /tmp/indico-pip indico && \
        unzip /tmp/indico-pip/indico-*.whl -d /srv/ 'indico/web/static/*' && \
        rm -rf /tmp/indico-pip

RUN rm /etc/nginx/conf.d/default.conf
COPY indico.conf /etc/nginx/conf.d/indico.conf

EXPOSE 8080
