# rebased/repackaged base image that only updates existing packages
FROM mbentley/alpine:latest
LABEL maintainer="Matt Bentley <mbentley@mbentley.net>"

RUN apk add --no-cache ca-certificates openldap openldap-back-mdb openldap-clients

# TODO:
#   * change ldap user from 100:101 to 911:911
#   * script to configure ldap or just rely on persistent volumes? (if volumes, what files are needed?)
#   * figure out SSL/TLS

#   * entrypoint script
#     * Use slaptest to validate config
#     * Figure out how to bootstrap custom config
#     * Proper way to use /etc/openldap/slapd.d directory?

VOLUME ["/var/lib/openldap/openldap-data"]

CMD ["slapd","-4","-u","ldap","-g","ldap","-d","256"]
