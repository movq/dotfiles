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
dig_cmd="${UACME_DIG_CMD:-dig}"
dns_resolver="${UACME_DNS_RESOLVER:-1.1.1.1}"
dns_wait_timeout="${UACME_DNS_WAIT_TIMEOUT:-180}"
dns_wait_interval="${UACME_DNS_WAIT_INTERVAL:-5}"
dns_ttl="${UACME_DNS_TTL:-10}"

if [ "$challenge_type" != "dns-01" ]; then
  exit 1
fi

if ! command -v "$dig_cmd" >/dev/null 2>&1; then
  echo "DNS lookup command not found: $dig_cmd" >&2
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

txt_present() {
  name="$1"
  value="$2"
  line=""

  txt="$($dig_cmd +time=2 +tries=1 +short TXT "$name" @"$dns_resolver" 2>/dev/null || true)"
  for line in $txt; do
    line=${line#\"}
    line=${line%\"}
    if [ "$line" = "$value" ]; then
      return 0
    fi
  done

  return 1
}

wait_for_txt_present() {
  name="$1"
  value="$2"
  elapsed=0

  while [ "$elapsed" -lt "$dns_wait_timeout" ]; do
    if txt_present "$name" "$value"; then
      return 0
    fi
    sleep "$dns_wait_interval"
    elapsed=$((elapsed + dns_wait_interval))
  done

  echo "timed out waiting for TXT record $name to contain challenge value" >&2
  return 1
}

case "$method" in
  begin)
    pdns_patch "{
      \"rrsets\": [{
        \"name\": \"$record_name\",
        \"type\": \"TXT\",
        \"ttl\": $dns_ttl,
        \"changetype\": \"REPLACE\",
        \"records\": [{\"content\": \"\\\"$auth\\\"\", \"disabled\": false}]
      }]
    }"
    wait_for_txt_present "$record_name" "$auth"
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
