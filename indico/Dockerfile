FROM python:2.7

ENV INDICO_VIRTUALENV="/opt/indico/.venv/bin" INDICO_CONFIG="/opt/indico/etc/indico.conf"

ARG pip="${INDICO_VIRTUALENV}/pip"

RUN apt-get update && apt-get install -y postgresql texlive-xetex && bash -c 'mkdir -p --mode=775 /opt/indico/{etc,tmp,log,assets,cache,archive,static}'

## Uncomment to install tex
# RUN apt-get install -y texlive-xetex

COPY run_indico.sh run_celery.sh /opt/indico/
RUN chmod 755 /opt/indico/run_*.sh

RUN virtualenv /opt/indico/.venv

RUN ${pip} install pgcli

RUN ${pip} install --upgrade pip && \
    ${pip} install --pre indico && \
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
