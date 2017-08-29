#!/bin/bash

while true; do
    read -p "Do you wish to use an external database? [y/n]: " yn
    case $yn in
        [Yy]* ) oc new-app -f indico.yml -p USE_EXTERNAL_DB=y; break;;
        [Nn]* ) oc new-app -f indico.yml -p USE_EXTERNAL_DB=n && oc create -f postgres.yml; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
