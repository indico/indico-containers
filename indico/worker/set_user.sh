#!/bin/sh
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
cp /etc/passwd /tmp/passwd
envsubst < ${HOME}/passwd.template >> /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

export KRB5CCNAME=${KRB_CACHE_DIR}
