# docker-opensim-python

## Build the image

```bash
docker compose build # docker-compose in older versions
```

## Or (instead) download the image

```bash
docker pull ghcr.io/roboticslab-uc3m/opensim-python:latest
```

## Additional configuration

`docker-compose.yaml` adding more `volumes`:

```yaml
    - /path/in/local:/path/in/docker
```

## Run

```bash
docker compose run --rm opensim # docker-compose in older versions
```
