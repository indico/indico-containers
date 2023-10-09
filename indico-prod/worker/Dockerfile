FROM python:3.10-bullseye

ENV INDICO_VIRTUALENV="/opt/indico/.venv" INDICO_CONFIG="/opt/indico/etc/indico.conf"

ARG KRB_CACHE_DIR='/var/run/keytab'
ARG pip="${INDICO_VIRTUALENV}/bin/pip"
ARG tag="latest"

ENV KRB_CACHE_DIR ${KRB_CACHE_DIR}

USER root

RUN set -ex && \
    apt-get update && \
    apt-get -y install texlive-xetex libpq-dev postgresql-client vim less gcc gettext && \
    apt-get clean

RUN ["/bin/bash", "-c", "mkdir -p --mode=775 /opt/indico/{etc,tmp,log,cache,archive}"]

RUN python -m venv ${INDICO_VIRTUALENV}

RUN ${pip} install --upgrade pip setuptools uwsgi

RUN apt-get install -y libldap2-dev

RUN if [ "$tag" = "latest" ]; then \
    ${pip} install indico; \
else \
    ${pip} install indico==${tag}; \
fi;
RUN ${pip} install indico-plugins

RUN ${INDICO_VIRTUALENV}/bin/indico setup create-symlinks /opt/indico
RUN ${INDICO_VIRTUALENV}/bin/indico setup create-logging-config /opt/indico/etc

EXPOSE 59999

COPY uwsgi.ini /etc/uwsgi.ini

VOLUME ${KRB_CACHE_DIR}

WORKDIR /opt/indico

# OpenShift runs containers using an arbitrarily assigned user ID for security reasons
# This user is always in the root group so it is needed to grant privileges to group 0.
RUN chgrp -R 0 /opt/indico

COPY run_indico.sh run_celery.sh set_user.sh /opt/indico/
RUN chmod 755 /opt/indico/*.sh
RUN chmod g=u /etc/passwd
