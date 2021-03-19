from nginx

RUN apt-get update -q \
	&& DEBIAN_FRONTEND=noninteractive \
	apt-get install -qy --no-install-recommends \
	cron gettext-base \
	&& apt-get autoremove \
	&& apt-get autoclean \
	&& rm -rf /var/lib/apt/lists/*

ARG SERVICE_HTTP_PORT
ARG SERVICE_HTTPS_PORT
EXPOSE $SERVICE_HTTP_PORT
EXPOSE $SERVICE_HTTPS_PORT

ENV ACME_DIR=/root/.acme.sh
ARG LETSENCRYPT_MAIL
RUN curl https://get.acme.sh | sh -s email=$LETSENCRYPT_MAIL \
    && mkdir -p /tmp/.well-known/acme-challenge/

RUN rm -f /etc/nginx/conf.d/default.conf

COPY secrets/mycert.crt /opt/secrets/
COPY secrets/mycert.key /opt/secrets/
COPY indico.conf.template /tmp/
COPY run.sh /tmp/

# OpenShift runs containers using an arbitrarily assigned user ID for security reasons
# This user is always in the root group so it is needed to grant privileges to group 0.
RUN chgrp -R 0 /var/* /etc/nginx && chmod -R g+rwX /var/* /etc/nginx

CMD /tmp/run.sh
