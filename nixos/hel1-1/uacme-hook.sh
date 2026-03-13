#!/bin/sh
set -eu

if [ "$#" -ne 5 ]; then
  echo "usage: $0 method type ident token auth" >&2
  exit 1
fi

method="$1"
challenge_type="$2"
ident="$3"
token="$4"
auth="$5"

if [ "$challenge_type" != "dns-01" ]; then
  exit 1
fi

api_key_file="/var/lib/uacme/private/pdns-api-key"
dns_api="https://dns-api.mjones.io/api/v1/servers/localhost/zones/mjones.io."

if [ ! -r "$api_key_file" ]; then
  echo "missing PowerDNS API key file: $api_key_file" >&2
  exit 1
fi

api_key="$(tr -d '\n' < "$api_key_file")"
if [ -z "$api_key" ]; then
  echo "PowerDNS API key file is empty: $api_key_file" >&2
  exit 1
fi

case "$ident" in
  \*.*) ident="${ident#*.}" ;;
esac

record_name="_acme-challenge.$ident."

pdns_patch() {
  curl --fail --silent --show-error \
    -X PATCH "$dns_api" \
    -H "X-API-Key: $api_key" \
    -H "Content-Type: application/json" \
    -d "$1"
}

case "$method" in
  begin)
    pdns_patch "{
      \"rrsets\": [{
        \"name\": \"$record_name\",
        \"type\": \"TXT\",
        \"ttl\": 60,
        \"changetype\": \"REPLACE\",
        \"records\": [{\"content\": \"\\\"$auth\\\"\", \"disabled\": false}]
      }]
    }"
    sleep 5
    ;;
  done|failed)
    pdns_patch "{
      \"rrsets\": [{
        \"name\": \"$record_name\",
        \"type\": \"TXT\",
        \"changetype\": \"DELETE\"
      }]
    }"
    ;;
  *)
    echo "invalid method: $method" >&2
    exit 1
    ;;
esac
