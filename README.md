# mbentley/swissarmy

docker image for small random utilities
based off of [mbentley/alpine:latest](https://github.com/mbentley/docker-base-alpine)

## Child Docker Images

The following Docker images are available from this repo:

* `mbentley/curl`
* `mbentley/bind-tools`
* `mbentley/jq`
* `mbentley/ldap-utils`

## Tools in `mbentley/swissarmy`

List of tools that this image provides:

* `bash`
* `bind-tools` (provides `dig`)
* `curl`
* `iperf3`
* `jq`
* `lynx`
* `netcat-openbsd` (provides `nc`)
* `openldap-clients` (ldap utilities)
* `util-linux` (provides `nsenter`)
* `vim`
* `wget`

To pull this image:
`docker pull mbentley/swissarmy`

## Example Usage

### `mbentley/swissarmy`

```bash
docker run -it --rm mbentley/swissarmy ping -c 4 google.com
```

### `mbentley/curl`

```bash
docker run -it --rm mbentley/curl http://www.google.com
```

### `mbentley/bind-tools`

```bash
docker run -it --rm mbentley/bind-tools dig @8.8.8.8 github.com

docker run -it --rm mbentley/bind-tools nslookup github.com
```

### `mbentley/jq`

```bash
$ cat test.json | docker run -i --rm mbentley/jq .
{
  "test": true,
  "test2": false
}
```

### `mbentley/ldap-utils`

```bash
# get usage
docker run -it --rm mbentley/ldap-utils

# example
docker run -it --rm mbentley/ldap-utils ldapurl -h ldap.domain.com
```
