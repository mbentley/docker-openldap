#!/bin/sh

set -e

DOMAIN="${DOMAIN:-example.com}"
BASE_DN="$(echo "${DOMAIN}" | sed 's/\./,dc=/' | sed 's/^/dc=/')"


# validate /etc/openldap/slapd.d exists
if [ ! -d "/etc/openldap/slapd.d" ]
then
  # missing directory
  echo "WARN: /etc/openldap/slapd.d missing; creating..."
  mkdir /etc/openldap/slapd.d
  chown -R ldap:ldap /etc/openldap/slapd.d
else
  # found the directory
  echo "INFO: found /etc/openldap/slapd.d; checking for previous config..."
fi

# validate & fix ownership
if [ "$(stat -c '%U:%G' /etc/openldap/slapd.d)" != "ldap:ldap" ]
then
  # ownership incorrect
  echo "WARN: ownership incorrect for /etc/openldap/slapd.d; setting to 'ldap:ldap'..."
  chown -R ldap:ldap /etc/openldap/slapd.d
fi

# check for previous config
if [ -f '/etc/openldap/slapd.d/cn=config.ldif' ] && [ -d '/etc/openldap/slapd.d/cn=config' ]
then
  # previous data found
  echo "INFO: previous data found in /etc/openldap/slapd.d; skipping bootstrap"
else
  # no data found

  # TODO: determine if we should do this via variable
  echo "INFO: replace base DN..."
  sed -i "s/dc=example,dc=com/${BASE_DN}/g" /etc/openldap/slapd.ldif

  echo "INFO: no previous data found in /etc/openldap/slapd.d; performing initial bootstrap from /etc/openldap/slapd.ldif..."
  su -s /bin/sh ldap -c 'slapadd -n 0 -F /etc/openldap/slapd.d -l /etc/openldap/slapd.ldif'
  echo "done";echo

  # TODO: configure importing data; use variable to determine if we should
  #echo "INFO: importing test..."
  #su -s /bin/sh ldap -c 'slapadd -F /etc/openldap/slapd.d -b "dc=my-domain,dc=com" -l /certs/test/users.ldif'
  #echo "done";echo
fi

# check for a valid config
echo "INFO: validaing cn=config in /etc/openldap/slapd.d..."
slaptest -F /etc/openldap/slapd.d -n 0
echo "done";echo

# execute CMD
echo "INFO: executing CMD '${*}'..."
exec "${@}"
