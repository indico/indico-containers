# indico-docker

[![Build Status](https://www.travis-ci.org/indico/indico-containers.svg?branch=master)](https://www.travis-ci.org/indico/indico-containers)

Simple Docker config to try Indico out.

**ATTENTION: DO NOT use this in production as it is. There are important things missing.**

```sh
$ make
$ docker-compose up
```


### OpenShift

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
