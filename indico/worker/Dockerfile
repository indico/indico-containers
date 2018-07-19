FROM centos:centos7

ENV INDICO_VIRTUALENV="/opt/indico/.venv/bin" INDICO_CONFIG="/opt/indico/etc/indico.conf"

ARG KRB_CACHE_DIR='/var/run/keytab'
ARG pip="${INDICO_VIRTUALENV}/pip"
ARG use_xrootd=""

ENV KRB_CACHE_DIR ${KRB_CACHE_DIR}

USER root

RUN yum update -y;
RUN yum install -y epel-release python-pip;
RUN yum localinstall -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
RUN yum update -y
RUN yum install -y postgresql96 && bash -c 'mkdir -p --mode=774 /opt/indico/{etc,tmp,log,assets,cache,archive,static}'

RUN if [ -n "${use_xrootd}" ]; then \
    yum update -y && \
    yum install -y xrootd-client xrootd-client-devel xrootd-python; \
fi
RUN yum install -y vim less python-virtualenv nss_wrapper gcc gettext
RUN yum clean all

COPY run_indico.sh run_celery.sh set_user.sh /opt/indico/
COPY passwd.template /tmp/
RUN chmod 755 /opt/indico/run_*.sh

RUN if [ -z "${use_xrootd}" ]; then \
    virtualenv /opt/indico/.venv; \
else \
    virtualenv /opt/indico/.venv --system-site-packages; \
fi

RUN ${pip} install pgcli

RUN ${pip} install --upgrade pip && \
    ${pip} install indico==2.1.2 && \
    ${pip} install uwsgi && \
    ${pip} install raven

RUN if [ -n "${use_xrootd}" ]; then \
    ${pip} install indico-plugin-storage-xrootd==1.0; \
fi

RUN ${INDICO_VIRTUALENV}/indico setup create_symlinks /opt/indico
RUN ${INDICO_VIRTUALENV}/indico setup create_logging_config /opt/indico/etc

COPY indico.conf logging.yaml /opt/indico/etc/

EXPOSE 59999

COPY uwsgi.ini /etc/uwsgi.ini

VOLUME ${KRB_CACHE_DIR}

# OpenShift runs containers using an arbitrarily assigned user ID for security reasons
# This user is always in the root group so it is needed to grant privileges to group 0.
RUN chgrp -R 0 /opt/indico
