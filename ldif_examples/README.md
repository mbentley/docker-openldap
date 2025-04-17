# LDIF Examples

Here are some ldif examples

There are other examples: https://github.com/osixia/docker-openldap/tree/master/image/service/slapd/assets/config

From the shell of the container:

## Add

```bash
ldapadd -Y EXTERNAL -H ldapi:/// -f <ldif-file-name>
```

## Modify

```bash
ldapmodify -Y EXTERNAL -H ldapi:/// -f <ldif-file-name>
```
