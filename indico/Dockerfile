FROM centos:7

ARG base_url

ENV INDICO_VIRTUALENV="/opt/indico/env/bin"
ENV INDICO_CONFIG=/opt/indico/etc/indico.conf

ARG pip="${INDICO_VIRTUALENV}/pip"

RUN useradd indico -g users -u 1000

RUN yum install -y python-devel python-virtualenv gcc libxml2-devel libxslt-devel postgresql postgresql-devel
RUN mkdir -p /opt/indico/{etc,tmp,log,assets,cache,archive}
RUN chown -R indico:users /opt/indico

COPY entrypoint.sh /opt/indico/entrypoint.sh
RUN chmod 755 /opt/indico/entrypoint.sh

USER indico
RUN virtualenv /opt/indico/env

RUN ${pip} install pgcli

RUN ${pip} install --upgrade pip
RUN ${pip} install https://pypi.python.org/packages/26/e4/9aafeddba9d28a81a8b40d85cdee9d674a93fe5040825ef1bb03287ea768/indico_fonts-1.1-py2.py3-none-any.whl#md5=eb8b908fdc2b25799cbc50ed380212ee
RUN ${pip} install https://github.com/pferreir/indico/releases/download/1.9.10.dev2/indico-1.9.10.dev2-py2-none-any.whl

RUN ${INDICO_VIRTUALENV}/indico-setup create_symlinks /opt/indico
RUN ${INDICO_VIRTUALENV}/indico-setup create_configs /opt/indico/etc

COPY indico.conf /opt/indico/etc/indico.conf
RUN sed -i "s/BASEURL/${base_url}/" /opt/indico/etc/indico.conf

VOLUME /opt/indico/archive
VOLUME /opt/indico/log

EXPOSE 8000

RUN echo ". $INDICO_VIRTUALENV/activate" > ~/.bashrc
ENTRYPOINT /opt/indico/entrypoint.sh
