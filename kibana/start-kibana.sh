#!/bin/bash
# Carga las contraseñas y claves desde archivos secretos al keystore de Kibana.
set -euo pipefail
cd /usr/share/kibana

if [ ! -f config/kibana.keystore ]; then
  bin/kibana-keystore create
fi

add_secret() {
  local key="$1" file="$2"
  printf '"%s"' "$(cat "$file")" |
    bin/kibana-keystore add "$key" --stdin --force --silent
}

add_secret elasticsearch.password /run/secrets/kibana_password
add_secret xpack.security.encryptionKey /run/secrets/kibana_session_key
add_secret xpack.encryptedSavedObjects.encryptionKey /run/secrets/kibana_saved_objects_key

exec /usr/local/bin/kibana-docker
