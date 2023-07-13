# docker-opensim-python

First install:

- [Docker](https://robots.uc3m.es/installation-guides/install-docker.html)

## Build the image

```bash
docker compose build # docker-compose in older versions
```

## Or (instead) download the image

```bash
docker pull ghcr.io/roboticslab-uc3m/opensim-python:latest
```

Once downloaded, upon `docker image ls` you'll see `ghcr.io/roboticslab-uc3m/opensim-python`.

## Additional configuration

`docker-compose.yaml` adding more `volumes`:

```yaml
    - /path/in/local:/path/in/docker
```

## Run

```bash
docker compose run --rm opensim # docker-compose in older versions
```
