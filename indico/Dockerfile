FROM python:2.7

ENV INDICO_VIRTUALENV="/opt/indico/.venv/bin"
ENV INDICO_CONFIG=/opt/indico/etc/indico.conf

ARG pip="${INDICO_VIRTUALENV}/pip"

RUN useradd indico -g users -u 1000

RUN apt update
RUN apt install -y postgresql
RUN bash -c 'mkdir -p /opt/indico/{etc,tmp,log,assets,cache,archive,static}'
RUN chown -R indico:users /opt/indico

COPY run_indico.sh run_celery.sh /opt/indico/
RUN chmod 755 /opt/indico/run_*.sh

USER indico
RUN virtualenv /opt/indico/.venv

RUN ${pip} install pgcli

RUN ${pip} install --upgrade pip
RUN ${pip} install https://pypi.python.org/packages/26/e4/9aafeddba9d28a81a8b40d85cdee9d674a93fe5040825ef1bb03287ea768/indico_fonts-1.1-py2.py3-none-any.whl#md5=eb8b908fdc2b25799cbc50ed380212ee
RUN ${pip} install --pre indico
RUN ${pip} install uwsgi

RUN ${INDICO_VIRTUALENV}/indico setup create_symlinks /opt/indico
RUN ${INDICO_VIRTUALENV}/indico setup create_configs /opt/indico/etc

COPY indico.conf /opt/indico/etc/indico.conf

COPY uwsgi.ini /etc/uwsgi.ini

# OpenShift runs containers using an arbitrarily assigned user ID for security reasons
# This user is always in the root group so it is needed to grant privileges to group 0.
RUN chgrp -R 0 /opt/indico && chmod -R g+rwX /opt/indico
