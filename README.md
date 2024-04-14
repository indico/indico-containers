# Docker containers for Indico

![Pipeline Status](https://github.com/indico/indico-containers/actions/workflows/ci.yml/badge.svg)

## Production-like setup

### Quickstart

Before starting the containers, set a `SECRET_KEY` in the [`indico-prod/indico.conf`](indico-prod/indico.conf) file. You can generate one by running the following snippet from the terminal:

```sh
python -c 'import os; print(repr(os.urandom(32)))'
```

Once this is done, start the containers with:

```sh
$ cd indico-prod && docker compose up
```

Indico will be accessible at [localhost:8080](localhost:8080). You can also access the wsgi app directly at [localhost:9090](localhost:9090) which skips the nginx proxy. If you do this, make sure to update `BASE_URL` in the [`indico-prod/indico.conf`](indico-prod/indico.conf) file.

### Configuration

There are a couple config files which you can use to configure this setup.
- [indico-prod/.env](indico-prod/.env) - This file specifies general settings like the DB config, nginx port and the path to `indico.conf`.
- [indico-prod/indico.conf](indico-prod/indico.conf) - This is a sample Indico config file. It is passed to the containers as a read-only volume. Feel free to modify it based on your needs. You can use a different config file by changing the `INDICO_CONFIG` variable in [indico-prod/.env](indico-prod/.env).
- [indico-prod/logging.yaml](indico-prod/logging.yaml) - The default logging config for Indico. Feel free to modify it or use a different config by changing the `INDICO_LOGGING_CONFIG` variable.

The production setup contains the following containers:
- _indico-web_ - Indico running behind uwsgi (accessible at [localhost:9090](localhost:9090))
- _indico-celery_ - Indico celery task runner
- _indico-celery-beat_ - celery beat
- _indico-redis_ - redis
- _indico-nginx_ - nginx proxy (by default accessible at [localhost:8080](localhost:8080), can be changed by updating `NGINX_PORT`)

_indico-web_ uses the `getindico/indico` image that we publish to Dockerhub. You can build this image locally using the [build_latest.sh](build_latest.sh) script. The image pulls the latest Indico release from PyPI together with the `indico-plugins` package. You can use the `indico.conf` file to specify which plugins you want to enable.

### Different setups

If you don't need the DB and the nginx proxy, you can just run:
```sh
$ docker compose up indico-web
```

This will bring up only Indico, celery and redis. The DB should be on the same network to be accessible.

The `getindico/indico` image can also be used completely standalone outside of this docker-compose setup, as long as the remaining services (postgres, redis, celery) are available elsewhere. In that case, make sure to update `REDIS_CACHE_URL`, `CELERY_BROKER` in your `indico.conf` and the DB connection settings in [prod.env](prod.env).

This is how you can run Indico on its own:
```sh
$ docker run \
    type=bind,src=/path/to/indico.conf,target=/opt/indico/etc/indico.conf \
    getindico/indico /opt/indico/run_indico.sh
```

Or to run celery from the same image:
```sh
$ docker run \
    type=bind,src=/path/to/indico.conf,target=/opt/indico/etc/indico.conf \
    getindico/indico /opt/indico/run_celery.sh
```

In the above, we omit the network setup to make e.g. the DB accessible from the containers.

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
