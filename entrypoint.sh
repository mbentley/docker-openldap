#!/bin/sh

set -e

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

  echo "INFO: no previous data found in /etc/openldap/slapd.d; performing initial bootstrap from /etc/openldap/slapd.ldif..."
  su -s /bin/sh ldap -c 'slapadd -n 0 -F /etc/openldap/slapd.d -l /etc/openldap/slapd.ldif'
  echo "done";echo
fi

# check for a valid config
echo "INFO: validaing the config db (0) in /etc/openldap/slapd.d..."
slaptest -F /etc/openldap/slapd.d -n 0
echo "done";echo

# execute CMD
echo "INFO: executing CMD '${*}'..."
exec "${@}"
