#!/bin/sh

set -e

HPA_DEFINITION=$(oc get hpa/indico-web-autoscaler -o yaml --export)

oc delete hpa/indico-web-autoscaler
oc tag indico:latest indico:previous
oc create -f - <<'EOF'
apiVersion: v1
kind: DeploymentConfig
metadata:
  creationTimestamp: null
  labels:
    app: indico-template
  name: indico-tmp
spec:
  replicas: 1
  selector:
    indico.web.service: indico-web-tmp
  strategy:
    resources: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        indico.web.service: indico-web-tmp
    spec:
      containers:
      - name: indico-web
        image: ' '
        args:
        - ./opt/indico/run_indico.sh
        readinessProbe:
          exec:
            command:
            - curl
            - 127.0.0.1:59999/contact
          initialDelaySeconds: 5
          timeoutSeconds: 20
        env:
        - name: SERVICE_PROTOCOL
          valueFrom:
            configMapKeyRef:
              key: serviceprotocol
              name: settings
        - name: SERVICE_HOSTNAME
          valueFrom:
            configMapKeyRef:
              key: servicehost
              name: settings
        - name: SERVICE_PORT
          valueFrom:
            configMapKeyRef:
              key: serviceport
              name: settings
        - name: PGHOST
          valueFrom:
            configMapKeyRef:
              key: pghost
              name: settings
        - name: PGUSER
          valueFrom:
            configMapKeyRef:
              key: pguser
              name: settings
        - name: PGPASSWORD
          valueFrom:
            configMapKeyRef:
              key: pgpassword
              name: settings
        - name: PGDATABASE
          valueFrom:
            configMapKeyRef:
              key: pgdatabase
              name: settings
        - name: PGPORT
          valueFrom:
            configMapKeyRef:
              key: pgport
              name: settings
        - name: SENTRY_DSN
          valueFrom:
            configMapKeyRef:
              key: sentrydsn
              name: settings
        - name: SECRET_KEY
          valueFrom:
            configMapKeyRef:
              key: secretkey
              name: settings
        - name: SMTP_SERVER
        - name: SMTP_PORT
        - name: SMTP_LOGIN
        - name: SMTP_PASSWORD
        - name: SMTP_USE_TLS
        - name: INDICO_DEFAULT_TIMEZONE
        - name: INDICO_DEFAULT_LOCALE
        - name: INDICO_ROUTE_OLD_URLS
        - name: INDICO_CHECKIN_APP_CLIENT_ID
        - name: INDICO_CUSTOMIZATION_DIR
        - name: INDICO_CUSTOMIZATION_DEBUG
        - name: INDICO_LOGO_URL
        - name: REDIS_CACHE_URL
          value: redis://indico-redis:6379/1
        - name: CELERY_BROKER
          value: redis://indico-redis:6379/0
        - name: SQLALCHEMY_DATABASE_URI
        - name: C_FORCE_ROOT
          value: "true"
        - name: USE_EXTERNAL_DB
          value: ${USE_EXTERNAL_DB}
        ports:
        - containerPort: 59999
        resources:
          limits:
            cpu: 800m
            memory: 2Gi
          requests:
            cpu: 400m
            memory: 512Mi
        volumeMounts:
        - mountPath: /opt/indico/archive
          name: indico-web-claim0
        - mountPath: /opt/indico/static
          name: static-files
        - mountPath: /opt/indico/custom
          name: customization
        - mountPath: /opt/indico/tmp
          name: indico-web-tmpfs0
      restartPolicy: Always
      volumes:
      - name: indico-web-claim0
        persistentVolumeClaim:
          claimName: indico-web-claim0
      - name: indico-web-claim1
        persistentVolumeClaim:
          claimName: indico-web-claim1
      - name: static-files
        persistentVolumeClaim:
          claimName: static-files
      - name: customization
        persistentVolumeClaim:
          claimName: customization
      - emptyDir:
          medium: Memory
        name: indico-web-tmpfs0
  test: false
  triggers:
  - type: ImageChange
    imageChangeParams:
      automatic: false
      containerNames:
      - indico-web
      from:
        kind: ImageStreamTag
        name: indico:previous
status: {}
EOF

oc rollout latest dc/indico-tmp && oc rollout status dc/indico-tmp
oc patch svc indico-web -p '{"spec": {"selector": {"indico.web.service": "indico-web-tmp"}}}'
oc scale dc/indico --replicas=1
oc start-build indico --wait && oc rollout status dc/indico

oc rsh dc/indico /bin/sh <<'EOF'
. /opt/indico/.venv/bin/activate
indico db upgrade
EOF

oc patch svc indico-web -p '{"spec": {"selector": {"indico.web.service": "indico-web"}}}'
#echo "$HPA_DEFINITION" | oc create -f -
oc delete dc/indico-tmp
oc tag indico:previous -d
