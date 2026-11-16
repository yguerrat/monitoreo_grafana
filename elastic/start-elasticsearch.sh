#!/bin/bash
# En Windows, Docker monta secretos con permisos amplios. Esta copia local cumple 0600.
set -euo pipefail
umask 077
cp /run/secrets/elastic_password /tmp/elastic_password
chmod 600 /tmp/elastic_password
export ELASTIC_PASSWORD_FILE=/tmp/elastic_password
exec /usr/local/bin/docker-entrypoint.sh eswrapper
