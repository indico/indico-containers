#!/bin/bash

while true; do
    read -p "Do you wish to use an external database? [y/n]: " yn
    case $yn in
        [Yy]* ) oc new-app -f indico.yml -p USE_EXTERNAL_DB=y; break;;
        [Nn]* ) oc new-app -f indico.yml -p USE_EXTERNAL_DB=n && oc create -f postgres.yml; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
while true; do
    read -p "Do you wish to use eos storage? [y/n]: " yn
    case $yn in
        [Yy]* ) read -p "EOS username: " username;
                read -sp "EOS password: " password;
                oc create secret generic eos-credentials --type=eos.cern.ch/credentials --from-literal=keytab-user=$username --from-literal=keytab-pwd=$password;
                oc set volume dc/indico --add --name=eos --type=persistentVolumeClaim --mount-path=/eos --claim-name=eos-volume --claim-class=eos --claim-size=0;
                oc patch dc/indico -p "$(cat eosclient-container-patch.json)";
                echo "Remember to update config map with storage settings, check readme for details";
                break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
