FROM python:3.12-trixie

ENV INDICO_VIRTUALENV="/opt/indico/.venv" INDICO_CONFIG="/opt/indico/etc/indico.conf"

ARG tag="latest"

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# create indico user, install apt dependencies as root and setup uwsgi etc.
USER root

RUN set -ex && \
    apt-get update && \
    apt-get -y install libpq-dev postgresql-client vim less gcc gettext libldap2-dev rsync podman && \
    apt-get clean

RUN set -ex && \
    groupadd -r indico && \
    useradd -r -g indico -m -d /opt/indico --add-subids-for-system indico

COPY uwsgi.ini /etc/uwsgi.ini
WORKDIR /opt/indico

RUN set -ex && \
    mkdir -p --mode=750 /opt/indico/etc && \
    mkdir -p --mode=777 /opt/indico/tmp && \
    mkdir -p --mode=750 /opt/indico/log && \
    mkdir -p --mode=750 /opt/indico/cache && \
    mkdir -p --mode=750 /opt/indico/archive && \
    mkdir -p --mode=750 /opt/indico/static-shared && \
    chown -R indico:indico /opt/indico

# XXX do we still need this?
RUN chmod g=u /etc/passwd

# all the installations etc can be done using the unprivileged indico user
USER indico

RUN set -ex && \
    python -m venv ${INDICO_VIRTUALENV} && \
    uv pip install uwsgi

RUN if [ "$tag" = "latest" ]; then \
    uv pip install indico; \
else \
    uv pip install indico==${tag}; \
fi;
RUN uv pip install indico-plugins

RUN ${INDICO_VIRTUALENV}/bin/indico setup create-symlinks /opt/indico

COPY --chown=indico:indico run_indico.sh run_celery.sh docker_entrypoint.sh /opt/indico/
RUN chmod 755 /opt/indico/*.sh

ENTRYPOINT ["/opt/indico/docker_entrypoint.sh"]
EXPOSE 59999
