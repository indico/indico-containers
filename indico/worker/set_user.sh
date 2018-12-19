#!/bin/sh
# this script adds the current user to /etc/passwd as per:
# https://docs.okd.io/latest/creating_images/guidelines.html#use-uid

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-indico}:x:$(id -u):0:${USER_NAME:-indico} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi
