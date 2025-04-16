# mbentley/openldap

docker image for openldap
based off of [mbentley/alpine:latest](https://github.com/mbentley/docker-base-alpine)

## Example Usage

### Create and Modify your `slapd.ldif`

Grab a copy of the file from the image by starting a temp container and copying out the default file then removing the temp container:

```bash
docker run -itd --name openldap mbentley/openldap sh
docker cp openldap:/etc/openldap/slapd.ldif .
docker rm -f openldap
```

Modify the `slapd.ldif` to meet your needs

### Start the container

```bash
docker run -it --rm \
  --name openldap \
  -p 389:389 \
  -v /path/to/slapd.ldif:/etc/openldap/slapd.ldif \
  -v /path/to/slapd.d:/etc/openldap/slapd.d \
  -v openldap-data:/var/lib/openldap/openldap-data \
  mbentley/openldap
```

## To Do

- [ ] entrypoint script - use slaptest to validate config (only works for the dir or the deprecated conf file)
- [ ]  allow for manual or automatic via env var bootstrapping
- [ ] ldif bootstrap
    `oldModuleLoad`
    `slapcat -n 0 | grep olcModuleLoad`
- [ ] add??? `olcModuleLoad: {2}refint`

