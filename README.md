# mbentley/openldap

docker image for openldap
based off of [mbentley/alpine:latest](https://github.com/mbentley/docker-base-alpine)

## Usage

### Environment Variables

Depending on the type of deployment you want to run, different environment variables are either required, optional, or invalid (invalid will typically not cause an issue if set but the setting has no impact):

| Environment Variable | [Basic](#basic) | [BYOD](#bring-your-own-data-byod) | [Custom](#custom-configuration) | Description |
| :------- | :---: | :--: | :----: | :--------- |
| `LDAP_DOMAIN` | :white_check_mark: | :white_check_mark: | :x: | sets the domain which is used by the LDAP server |
| `LDAP_BASE_DN` | :o: | :o: | :x: | generated by the entrypoint script but if it is provided, will override the Base DN. The default will convert a domain like `example.com` to `dc=example,dc=com` |
| `LDAP_CONFIG_PASSWORD` | :white_check_mark: | :white_check_mark: | :x: | sets the password for `cn=admin,cn=config` which can be used to remotely configure the server |
| `LDAP_ADMIN_PASSWORD` | :white_check_mark: | :white_check_mark: | :x: | sets the password for `cn=admin,dc=example,dc=com` (where `dc=example,dc=com` gets replaced by the value of `LDAP_BASE_DN` during bootstrapping)|
| `FIRST_RUN_ADD` | :o: | :o: | :o: | imports data from `ldif` files mounted into the `/etc/openldap/imports` directory |
| `CUSTOM_SLAPD_LDIF` | :o: | :o: | :white_check_mark: | assumes the user is mounting their own custom `slapd.ldif` over `/etc/openldap/slapd.ldif`, bypassing much of the bootstrap automation |

__Key__: :white_check_mark: = required `|` :o: = optional `|` :x: = invalid

### Basic

Start a simple LDAP server with an empty database for `example.com` / `dc=example,dc=com`:

```bash
docker run -it --rm \
  --name openldap \
  --ulimit nofile=1024:1024 \
  -p 389:389 \
  -e LDAP_DOMAIN="example.com" \
  -e LDAP_CONFIG_PASSWORD="configsecret" \
  -e LDAP_ADMIN_PASSWORD="adminsecret" \
  -v openldap-data:/var/lib/openldap/openldap-data \
  -v openldap-slapd.d:/etc/openldap/slapd.d \
  mbentley/openldap
```

### Bring Your Own Data (BYOD)

The image has been built so that it can iterate over a list of files in a directory, in alpha-numeric order, and import them into the database. The files need to be mounted inside the container at `/etc/openldap/imports`, the `cn=config` database must be empty (a new deployment), and the environment variable `FIRST_RUN_ADD` must be set to `true`:

```bash
docker run -it --rm \
  --name openldap \
  --ulimit nofile=1024:1024 \
  -p 389:389 \
  -e LDAP_DOMAIN="example.com" \
  -e FIRST_RUN_ADD=true \
  -v openldap-data:/var/lib/openldap/openldap-data \
  -v openldap-slapd.d:/etc/openldap/slapd.d \
  -v /path/to/ldif/files:/etc/openldap/imports \
  mbentley/openldap
```

### Custom Configuration

If you don't know where to start with a custom `slapd.ldif`, see the section below. Otherwise, start the container with `CUSTOM_SLAPD_LDIF` set to `true` and your `slapd.ldif` mounted over the existing `/etc/openldap/slapd.ldif` file:

```bash
docker run -it --rm \
  --name openldap \
  --ulimit nofile=1024:1024 \
  -p 389:389 \
  -e CUSTOM_SLAPD_LDIF=true \
  -v /path/to/custom/slapd.ldif:/etc/openldap/slapd.ldif \
  -v openldap-data:/var/lib/openldap/openldap-data \
  -v openldap-slapd.d:/etc/openldap/slapd.d \
  mbentley/openldap
```

#### Where to find an example `slapd.ldif`

There are several sources that have examples: you can grab a copy from the [openldap source code repository](https://git.openldap.org/openldap/openldap/-/blob/master/servers/slapd/slapd.ldif), from [this repository](slapd.ldif), or grab a copy of the file from the image by starting a temp container and copying out the default file then removing the temp container:

```bash
docker run -itd --name openldap --entrypoint sh mbentley/openldap -l
docker cp openldap:/etc/openldap/slapd.ldif .
docker rm -f openldap
```

Just note that there are a few variables in the version from this repository, which is also in the container image. They look like `{{ VARIABLE_NAME }}`. Modify the `slapd.ldif` to meet your needs.

## Loading data

To Do... add info on loading initial data
