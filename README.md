# docker-opensim-python

First install:

- [Docker](https://robots.uc3m.es/installation-guides/install-docker.html)

## Obtain the image

### Building the image via Docker Compose 

```bash
docker compose build # docker-compose in older versions
```

### Or (instead) downloading the image via Docker Pull

```bash
docker pull ghcr.io/roboticslab-uc3m/opensim-python:latest
```

Once downloaded, upon `docker image ls` you'll see `ghcr.io/roboticslab-uc3m/opensim-python`.

## Run via Docker Compose

### Configure Docker Compose

You can edit `docker-compose.yaml` adding more `volumes`:

```yaml
    - /path/in/local:/path/in/docker
```

## Actually run via Docker Compose

```bash
docker compose run --rm opensim # docker-compose in older versions
```
