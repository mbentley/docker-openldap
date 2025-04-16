# rebased/repackaged base image that only updates existing packages
FROM mbentley/alpine:latest
LABEL maintainer="Matt Bentley <mbentley@mbentley.net>"

RUN apk add --no-cache ca-certificates openldap openldap-back-mdb openldap-clients openldap-overlay-all openssl shadow &&\
  usermod -o -u 911 ldap &&\
  groupmod -o -g 911 ldap &&\
  mkdir /etc/openldap/slapd.d &&\
  chgrp ldap /etc/openldap/slapd.conf /etc/openldap/slapd.ldif &&\
  chown -R ldap:ldap /etc/openldap/slapd.d /var/lib/openldap /run/openldap &&\
  ln -s /run/openldap /var/lib/openldap/run

COPY entrypoint.sh /

VOLUME ["/etc/openldap/slapd.d","/var/lib/openldap/openldap-data"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["slapd","-4","-u","ldap","-g","ldap","-d","256","-h","ldap:/// ldapi:///"]
