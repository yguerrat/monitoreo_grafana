#!/bin/bash
# Guarda la contraseña de Elasticsearch en el keystore de Logstash.
set -euo pipefail
cd /usr/share/logstash
export LOGSTASH_KEYSTORE_PASS="$(cat /run/secrets/logstash_keystore_password)"

if [ ! -f config/logstash.keystore ]; then
  bin/logstash-keystore create
fi
if ! bin/logstash-keystore list | grep -qi '^logstash_password$'; then
  bin/logstash-keystore add LOGSTASH_PASSWORD --stdin < /run/secrets/logstash_password
fi

exec /usr/local/bin/docker-entrypoint
