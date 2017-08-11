#!/bin/bash

while true; do
    read -p "Do you wish to use DBoD? [y/n]: " yn
    case $yn in
        [Yy]* ) oc new-app -f indico.yml -p USE_DBOD=y; break;;
        [Nn]* ) oc new-app -f indico.yml -p USER_DBOD=n && oc create -f postgres.yml break;;
        * ) echo "Please answer yes or no.";;
    esac
done
