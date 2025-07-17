#!/bin/bash

if [[ -z $TRANSIFEX_API_TOKEN ]]; then
    echo "Transifex API token not provided"
    echo "Pulling translations from a mirror..."
    cd /opt/indico/src
    wget --tries=5 https://test-indico-transifex-mirror.app.cern.ch/translations.zip
    if [ $? -ne 0 ]; then
        echo "Failed to pull from mirror"
        exit 1
    fi
    unzip translations.zip
    # Delete existing translations
    rm -R indico/translations/*/
    # Move the current translations
    mv translations/* indico/translations/
    rm -r translations
else
    echo "Transifex API token provided"
    echo "Pulling translations from Transifex..."
    cd /opt/indico/src && /opt/tx/tx --token=$TRANSIFEX_API_TOKEN --root-config=/opt/indico/etc/.transifexrc pull --all -f
fi
