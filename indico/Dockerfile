FROM python:2.7-stretch

ENV INDICO_VIRTUALENV="/opt/indico/.venv/bin" INDICO_CONFIG="/opt/indico/etc/indico.conf"

ARG pip="${INDICO_VIRTUALENV}/pip"

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' > /etc/apt/sources.list.d/postgresql.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get install -y postgresql-9.6 && bash -c 'mkdir -p --mode=774 /opt/indico/{etc,tmp,log,assets,cache,archive,static}'
RUN apt-get install -y vim less

COPY run_indico.sh run_celery.sh /opt/indico/
RUN chmod 755 /opt/indico/run_*.sh

RUN virtualenv /opt/indico/.venv

RUN ${pip} install pgcli

RUN ${pip} install --upgrade pip && \
    ${pip} install indico==2.1 && \
    ${pip} install uwsgi && \
    ${pip} install raven

RUN ${INDICO_VIRTUALENV}/indico setup create_symlinks /opt/indico
RUN ${INDICO_VIRTUALENV}/indico setup create_logging_config /opt/indico/etc

COPY indico.conf logging.yaml /opt/indico/etc/

EXPOSE 59999

COPY uwsgi.ini /etc/uwsgi.ini

# OpenShift runs containers using an arbitrarily assigned user ID for security reasons
# This user is always in the root group so it is needed to grant privileges to group 0.
RUN chgrp -R 0 /opt/indico
