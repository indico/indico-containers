# Docker containers for Indico

## Production-like setup

[![Build Status](https://www.travis-ci.org/indico/indico-containers.svg?branch=master)](https://www.travis-ci.org/indico/indico-containers)

Before you run this setup, you might want to configure some environment variables.
There is also a [sample env file](indico.prod.env.sample) which you can start with:
```bash
$ cp indico.prod.env.sample indico.prod.env
```

To start the containers, run:
```sh
$ docker compose up
```

Indico will be accessible at [localhost:8080](localhost:8080). You can also access the wsgi app directly [localhost:9090](localhost:9090) which skips the nginx proxy.

The production setup contains:
- _indico-web_ - Indico running behind uwsgi ([localhost:9090](localhost:9090))
- _indico-celery_ - Indico celery task runner
- _indico-redis_ - redis
- _indico-nginx_ - nginx proxy ([localhost:8080](localhost:8080))

_indico-web_ uses the `getindico/indico` image from Dockerhub. You can build this image locally using `build_latest.sh`. The `getindico/indico` pulls the latest Indico release from PyPI together with the `indico-plugins` package. You can use the `INDICO_EXTRA_PLUGINS` env variable to enable them. For example, you can set `INDICO_EXTRA_PLUGINS=vc_zoom,owncloud` to enable the Zoom and ownCloud integration.

The `getindico/indico` container can also be used standalone outside of this docker-compose setup, as long as the remaning services (postgres, redis, celery) are available elsewhere. In that case, make sure to specify `REDIS_CACHE_URL`, `CELERY_BROKER`, `PGHOST`, `PGUSER`, etc..

This is how you can run Indico:
```bash
$ docker run getindico/indico /opt/indico/run_indico.sh
```

Or to run celery:
```bash
$ docker run getindico/indico /opt/indico/run_celery.sh
```

These examples omit the port mappings in order to make e.g. the DB accessible from the container.

## OpenShift

```sh
$ oc create configmap settings --from-literal=baseurl=<base_url> --from-literal=pgdatabase=<db_name>
--from-literal=pghost=<db_host> --from-literal=pguser=<db_user> --from-literal=pgport=<db_port>
--from-literal=pgpassword=<db_password> --from-literal=sentrydsn=<sentrydsn> --from-literal=secretkey=<secretkey>
--from-literal=storage=<storage> --from-literal=attachmentstorage=<attachment_storage>


$ cd openshift/
$ ./create.sh
```

In case you want to run the postgres container instead of DBoD (DataBase On Demand), keep in mind to set the `pghost`
literal as `indico-postgres` and the rest of literals accordingly:

```sh
$ oc create configmap settings --from-literal=baseurl=<base_url> --from-literal=pgdatabase=indico
--from-literal=pghost=indico-postgres --from-literal=pguser=indico --from-literal=pgport=5432
--from-literal=pgpassword=indicopass --from-literal=sentrydsn=<sentrydsn> --from-literal=secretkey=<secretkey>
--from-literal=storage=<storage> --from-literal=attachmentstorage=<attachment_storage>
```

If you want to use EOS storage you need to:

- add path to EOS in storage dict (settings configmap), for example:

```
    {'eos' : 'fs:/eos/path/to/folder'}
```

- set attachment storage to one of the defined storages, for example "eos"
