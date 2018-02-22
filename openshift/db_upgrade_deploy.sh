#!/bin/sh

set -e

HPA_DEFINITION=$(oc get hpa/indico-web-autoscaler -o json --export)

oc delete hpa/indico-web-autoscaler
oc tag indico:latest indico:previous

DC_DEFINITION=$(python <<EOF
import json

dc_data = json.loads('''`oc get dc/indico -o json --export`''')
dc_data['metadata']['labels']['indico.web.service'] = 'indico-web-tmp'
dc_data['metadata']['name'] = 'indico-tmp'
dc_data['spec']['selector']['indico.web.service'] = 'indico-web-tmp'
dc_data['spec']['template']['metadata']['labels']['indico.web.service'] = 'indico-web-tmp'
dc_data['spec']['template']['spec']['containers'][0]['image'] = ' '
dc_data['spec']['triggers'][1]['imageChangeParams']['automatic'] = False
dc_data['spec']['triggers'][1]['imageChangeParams']['from']['name'] = 'indico:previous'

print json.dumps(dc_data)
EOF
)

echo $DC_DEFINITION | oc create -f -

oc rollout latest dc/indico-tmp && oc rollout status dc/indico-tmp
oc patch svc indico-web -p '{"spec": {"selector": {"indico.web.service": "indico-web-tmp"}}}'
oc scale dc/indico --replicas=1
oc start-build indico --wait && oc rollout status dc/indico

oc rsh dc/indico /opt/indico/.venv/bin/indico db upgrade

oc patch svc indico-web -p '{"spec": {"selector": {"indico.web.service": "indico-web"}}}'
echo $HPA_DEFINITION | oc create -f -
oc delete dc/indico-tmp
oc tag indico:previous -d
