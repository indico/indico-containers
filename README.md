# indico-docker

Simple Docker config to try Indico out.

```sh
$ docker-compose up
```

To run Indico with your own database (prevents running postgres container), make sure you properly configure the
environmental variables for `indico-web` service in `docker-compose.yml` and run the following command instead:

```sh
$ docker-compose up indico-web
```
