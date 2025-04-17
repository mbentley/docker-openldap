#!/bin/sh

set -e

# set variables
LDAP_DOMAIN="${LDAP_DOMAIN:-example.com}"
LDAP_BASE_DN="${LDAP_BASE_DN:-$(echo "${LDAP_DOMAIN}" | sed 's/\./,dc=/g' | sed 's/^/dc=/')}"
FIRST_RUN_ADD="${FIRST_RUN_ADD:-false}"
CUSTOM_SLAPD_LDIF="${CUSTOM_SLAPD_LDIF:-false}"

LDAP_CONFIG_PASSWORD="${LDAP_CONFIG_PASSWORD:-configsecret}"
LDAP_ADMIN_PASSWORD="${LDAP_ADMIN_PASSWORD:-adminsecret}"

# password generating function
gen_password() {
  slappasswd -n -h '{SSHA}' -s "${@}"
}

# validate /etc/openldap/slapd.d exists
if [ ! -d "/etc/openldap/slapd.d" ]
then
  # missing directory
  echo "WARN: /etc/openldap/slapd.d missing; creating..."
  mkdir /etc/openldap/slapd.d
  chown -R ldap:ldap /etc/openldap/slapd.d
  chmod 700 /etc/openldap/slapd.d
fi

# validate & fix ownership
if [ "$(stat -c '%U:%G' /etc/openldap/slapd.d)" != "ldap:ldap" ]
then
  # ownership incorrect
  echo "WARN: ownership incorrect for /etc/openldap/slapd.d; setting to 'ldap:ldap'..."
  chown -R ldap:ldap /etc/openldap/slapd.d
  chmod 700 /etc/openldap/slapd.d
fi

# TODO: verify permissions

# verify data directory & permissions
if [ ! -d "/var/lib/openldap/openldap-data" ]
then
  echo "WARN: /var/lib/openldap/openldap-data missing; creating & setting permissions..."
  mkdir /var/lib/openldap/openldap-data
  chown ldap:ldap /var/lib/openldap/openldap-data
  chmod 700 /var/lib/openldap/openldap-data
fi

# validate & fix ownership
if [ "$(stat -c '%U:%G' /var/lib/openldap/openldap-data)" != "ldap:ldap" ]
then
  # ownership incorrect
  echo "WARN: ownership incorrect for /var/lib/openldap/openldap-data; setting to 'ldap:ldap'..."
  chown -R ldap:ldap /var/lib/openldap/openldap-data
  chmod 700 /var/lib/openldap/openldap-data
fi

# TODO: verify permissions

# notify about checking for previous config
echo "INFO: checking for previous cn=config in /etc/openldap/slapd.d..."

# check for previous config
if [ -f '/etc/openldap/slapd.d/cn=config.ldif' ] || [ -d '/etc/openldap/slapd.d/cn=config' ]
then
  # previous data found
  echo "INFO: cn=config found in /etc/openldap/slapd.d; skipping bootstrap"

  # output message if set
  if [ "${FIRST_RUN_ADD}" = "true" ]
  then
    echo "WARN: FIRST_RUN_ADD=true but existing data found; skipping ldif import (you can remove this env var to remove this warning)..."
  fi
else
  # no data found; see if user is bringing their own slapd.ldif
  if [ "${CUSTOM_SLAPD_LDIF}" = "true" ]
  then
    # expect a custom ldif to have been mounted at /etc/openldap/slapd.ldif
    echo "INFO: skipping /etc/openldap/slapd.ldif modifications; custom user defined slapd.ldif expected"
  else
    # no custom ldif provided; output details
    echo "INFO: server settings:"
    echo "  LDAP domain:   ${LDAP_DOMAIN}"
    echo "  LDAP Base DN:  ${LDAP_BASE_DN}"
    echo

    # update base dn
    echo "INFO: inserting Base DN (${LDAP_BASE_DN}) into /etc/openldap/slapd.ldif..."
    sed -i "s#dc=example,dc=com#${LDAP_BASE_DN}#g" /etc/openldap/slapd.ldif

    # update config password
    echo "INFO: inserting cn=config password into /etc/openldap/slapd.ldif..."
    sed -i "s#{{ LDAP_CONFIG_PASSWORD }}#$(gen_password "${LDAP_CONFIG_PASSWORD}")#g" /etc/openldap/slapd.ldif

    # update rootdn password
    echo "INFO: inserting admin password into /etc/openldap/slapd.ldif..."
    sed -i "s#{{ LDAP_ADMIN_PASSWORD }}#$(gen_password "${LDAP_ADMIN_PASSWORD}")#g" /etc/openldap/slapd.ldif
  fi

  # perform the initial bootstrap
  echo "INFO: performing initial cn=config bootstrap from /etc/openldap/slapd.ldif..."
  su -s /bin/sh ldap -c 'slapadd -n 0 -F /etc/openldap/slapd.d -l /etc/openldap/slapd.ldif'

  # only do this if this is our first run on a new deployment
  if [ "${FIRST_RUN_ADD}" = "true" ] && [ ! -d /etc/openldap/imports ]
  then
    # missing the imports directory
    echo "ERROR: FIRST_RUN_ADD=true but the directory /etc/openldap/imports does not exist!"
  elif [ "${FIRST_RUN_ADD}" = "true" ]
  then
    echo "INFO: importing ldif file(s) from /etc/openldap/imports..."

    # loop through files in /etc/openldap/imports
    for LDIF_FILE in /etc/openldap/imports/*.ldif
    do
      echo "INFO: processing ${LDIF_FILE}..."
      su -s /bin/sh ldap -c "slapadd -F /etc/openldap/slapd.d -b \"${LDAP_BASE_DN}\" -l \"${LDIF_FILE}\""
    done
    echo
  fi
fi

# check for a valid config
echo "INFO: validaing cn=config in /etc/openldap/slapd.d..."
slaptest -F /etc/openldap/slapd.d -n 0

# execute CMD
echo;echo "INFO: executing CMD '${*}'..."
exec "${@}"
