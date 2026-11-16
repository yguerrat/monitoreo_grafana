#!/bin/bash
# Crea cuentas para Kibana, Logstash y alumnos con permisos separados.
set -euo pipefail

elastic_password="$(cat /run/secrets/elastic_password)"
kibana_password="$(cat /run/secrets/kibana_password)"
logstash_password="$(cat /run/secrets/logstash_password)"
alumno_password="$(cat /run/secrets/alumno_password)"
api="http://elasticsearch:9200"

put_json() {
  local path="$1"
  curl --fail --silent --show-error \
    --user "elastic:${elastic_password}" \
    --header 'Content-Type: application/json' \
    --request PUT "${api}${path}" --data-binary @- >/dev/null
}

printf '{"password":"%s"}' "$kibana_password" |
  put_json '/_security/user/kibana_system/_password'

cat <<'JSON' | put_json '/_security/role/logstash_writer_lab'
{"cluster":["monitor"],"indices":[{"names":["logstash-*"],"privileges":["create_index","create","write"]}]}
JSON
printf '{"password":"%s","roles":["logstash_writer_lab"]}' "$logstash_password" |
  put_json '/_security/user/logstash_internal'

cat <<'JSON' | put_json '/_security/role/logstash_reader_lab'
{"indices":[{"names":["logstash-*"],"privileges":["read","view_index_metadata"]}]}
JSON
printf '{"password":"%s","roles":["kibana_admin","logstash_reader_lab"]}' "$alumno_password" |
  put_json '/_security/user/alumno'

echo 'Cuentas internas y usuario alumno configurados.'
