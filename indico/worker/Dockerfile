FROM centos:centos7

ENV INDICO_VIRTUALENV="/opt/indico/.venv/bin" INDICO_CONFIG="/opt/indico/etc/indico.conf"

ARG pip="${INDICO_VIRTUALENV}/pip"

USER root

RUN yum update -y;
RUN yum install -y epel-release python-pip;
RUN yum localinstall -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
RUN yum update -y
RUN yum install -y postgresql96 && bash -c 'mkdir -p --mode=774 /opt/indico/{etc,tmp,log,assets,cache,archive,static}'

RUN yum install -y vim less python-virtualenv nss_wrapper gcc gettext
RUN yum clean all

COPY run_indico.sh run_celery.sh set_user.sh /opt/indico/
COPY passwd.template /root
RUN chmod 755 /opt/indico/run_*.sh

RUN virtualenv /opt/indico/.venv

RUN ${pip} install pgcli

RUN ${pip} install --upgrade pip && \
    ${pip} install indico==2.1.2 && \
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
