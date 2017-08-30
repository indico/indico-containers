# indico-docker

Simple Docker config to try Indico out.

```sh
$ docker-compose up
```

To run Indico with your own database (prevents running postgres container), make sure you properly configure the
environment variables for `indico-web` service in `docker-compose.yml` and run the following command instead:

```sh
$ docker-compose up indico-web
```


### OpenShift

```sh
$ oc create configmap settings --from-literal=baseurl=<base_url> --from-literal=pgdatabase=<db_name>
--from-literal=pghost=<db_host> --from-literal=pguser=<db_user> --from-literal=pgport=<db_port>
--from-literal=pgpassword=<db_password>

$ cd openshift/
$ ./create.sh
```

In case you want to run the postgres container instead of DBoD (DataBase On Demand), keep in mind to set the `pghost`
literal as `indico-postgres` and the rest of literals accordingly:

```sh
$ oc create configmap settings --from-literal=baseurl=<base_url> --from-literal=pgdatabase=indico
--from-literal=pghost=indico-postgres --from-literal=pguser=indico --from-literal=pgport=5432
--from-literal=pgpassword=indicopass
