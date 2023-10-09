FROM cern/cc7-base

ARG KRB_CACHE_DIR='/var/run/keytab'

ENV KEYTAB_PATH '/var/lib/secrets'
ENV KRB_CACHE_DIR ${KRB_CACHE_DIR}
RUN yum install -y kstart krb5-workstation && yum clean all

COPY run.sh /

RUN mkdir -p $KEYTAB_PATH && chmod a+rw $KEYTAB_PATH && chmod a+x /run.sh

VOLUME ${KRB_CACHE_DIR}

ENTRYPOINT ["./run.sh"]
