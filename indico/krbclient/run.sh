#! /bin/sh
#
# Based on https://gitlab.cern.ch/paas-tools/eosclient-openshift/blob/2a2cb2c914c8ff8e775ad16643f6375a8bcaa3ee/run.sh
#
# The image supports the keytab to be passed either as mounted volume in $KEYTAB_PATH
# or the username and password of an account in KEYTAB_USER and KEYTAB_PWD

echo "KRB_CACHE_DIR = ${KRB_CACHE_DIR}"

# Abort if there are more than one keytab
if [[ $(ls -1 $KEYTAB_PATH | wc -l) != 1 ]];
then
  # If the keytab is in an environment variable, dump it into a file in $KEYTAB_PATH
  if [[ ! -z $KEYTAB_USER  && ! -z $KEYTAB_PWD ]]; then
    echo "Generating a keytab for '$KEYTAB_USER' using password in KEYTAB_PWD environment variable..."
    echo -e "addent -password -p $KEYTAB_USER@CERN.CH -k 1 -e rc4-hmac\n$KEYTAB_PWD\nwkt $KEYTAB_PATH/secret.keytab\nquit" | ktutil
  else
    echo "ERROR: A single keytab must be mounted in '${KEYTAB_PATH}' or a user and password combination for the user must be passed in 'KEYTAB_USER' and 'KEYTAB_PWD'"
    exit 1
  fi
fi

USER_ID=$(id -u)
KTAB_CACHE=$KEYTAB_PATH/*
HOST_KRB5_CACHE=$KRB_CACHE_DIR/user.krb5

k5start -f $KTAB_CACHE -k $HOST_KRB5_CACHE -K 30 -l 24h -U

if [[ ! $? -eq 0 ]]; then
  echo "Failure to obtain a ticket for user ${KEYTAB_USER} with provided password. Please verify if they are valid and if the account is activated."
  exit 2
fi
