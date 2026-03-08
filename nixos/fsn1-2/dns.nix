{ config, lib, pkgs, ... }:

let
  uacmeDnsHook = pkgs.writeShellScript "uacme-dns-hook.sh" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    export PATH=${lib.makeBinPath [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.systemd
      pkgs.util-linux
    ]}

    ARGS=5
    if [ "$#" -ne "$ARGS" ]; then
      echo "Usage: $(basename "$0") method type ident token auth" >&2
      exit 85
    fi

    METHOD="$1"
    TYPE="$2"
    IDENT="$3"
    TOKEN="$4"
    AUTH="$5"

    if [ "$TYPE" != "dns-01" ]; then
      exit 1
    fi

    readonly NSD_STATE_DIR="/var/lib/nsd"
    readonly ZONES_DIR="$NSD_STATE_DIR/zones"
    readonly CHALLENGE_DIR="$NSD_STATE_DIR/acme-challenges"
    readonly LOCK_FILE="$CHALLENGE_DIR/.lock"

    ZONES=(
${lib.concatMapStringsSep "\n" (zone: "      " + lib.escapeShellArg (lib.removeSuffix "." zone)) (lib.attrNames config.services.nsd.zones)}
    )

    normalize_ident() {
      local ident="$1"
      ident="''${ident%.}"
      case "$ident" in
        \*.*)
          ident="''${ident#*.}"
          ;;
      esac
      printf '%s' "$ident"
    }

    find_zone() {
      local ident="$1"
      local best=""

      for zone in "''${ZONES[@]}"; do
        if [ "$ident" = "$zone" ] || [[ "$ident" == *."$zone" ]]; then
          if [ "''${#zone}" -gt "''${#best}" ]; then
            best="$zone"
          fi
        fi
      done

      if [ -z "$best" ]; then
        return 1
      fi

      printf '%s' "$best"
    }

    ensure_zone_include() {
      local zone="$1"
      local zone_file="$ZONES_DIR/''${zone}."
      local include_file="$CHALLENGE_DIR/''${zone}.zone"
      local include_line="\$INCLUDE $include_file"

      if [ ! -f "$zone_file" ]; then
        echo "NSD zone file not found: $zone_file" >&2
        return 1
      fi

      if ! grep -Fqx "$include_line" "$zone_file"; then
        printf '\n%s\n' "$include_line" >> "$zone_file"
      fi

      touch "$include_file"
      chmod 0640 "$include_file"
      chown root:nsd "$include_file"
    }

    update_challenge_file() {
      local method="$1"
      local zone="$2"
      local ident="$3"
      local auth="$4"
      local include_file="$CHALLENGE_DIR/''${zone}.zone"
      local rr="_acme-challenge.''${ident}. 60 IN TXT \"''${auth}\""

      ensure_zone_include "$zone"

      case "$method" in
        begin)
          if ! grep -Fqx "$rr" "$include_file"; then
            printf '%s\n' "$rr" >> "$include_file"
          fi
          ;;
        done|failed)
          local tmp
          tmp="$(mktemp "''${include_file}.XXXXXX")"
          grep -Fvx -- "$rr" "$include_file" > "$tmp" || true
          mv "$tmp" "$include_file"
          chmod 0640 "$include_file"
          chown root:nsd "$include_file"
          ;;
        *)
          echo "$0: invalid method" >&2
          return 1
          ;;
      esac
    }

    IDENT_NORMALIZED="$(normalize_ident "$IDENT")"
    ZONE="$(find_zone "$IDENT_NORMALIZED")" || {
      echo "No NSD zone configured for identifier: $IDENT" >&2
      exit 1
    }

    mkdir -p "$CHALLENGE_DIR"
    chmod 0750 "$CHALLENGE_DIR"
    chown root:nsd "$CHALLENGE_DIR"

    exec 9>"$LOCK_FILE"
    flock 9

    update_challenge_file "$METHOD" "$ZONE" "$IDENT_NORMALIZED" "$AUTH"
    systemctl start nsd-dnssec.service

    if [ "$METHOD" = "begin" ]; then
      sleep 5
    fi
  '';
in
{
  services.nsd = {
    enable = true;
    # Listen on public addresses (default is loopback only).
    interfaces = [
      "135.181.178.34"
      "2a01:4f9:3a:201f::1"
    ];

    zones = {
      "mjones.io." = {
        dnssec = true;
        data = ''
          ; TODO: replace placeholder records.
          $ORIGIN mjones.io.
          $TTL 3600
          @ IN SOA ns1.mjones.io. hostmaster.mjones.io. (
            2026010101 ; serial
            3600       ; refresh
            900        ; retry
            1209600    ; expire
            3600       ; minimum
          )
          @ IN NS ns1.mjones.io.
          ns1 IN A 192.0.2.53
          ns1 IN AAAA 2001:db8::53
        '';
      };

      "mjones.org." = {
        dnssec = true;
        data = ''
          ; TODO: replace placeholder records.
          $ORIGIN mjones.org.
          $TTL 3600
          @ IN SOA ns1.mjones.org. hostmaster.mjones.org. (
            2026010101 ; serial
            3600       ; refresh
            900        ; retry
            1209600    ; expire
            3600       ; minimum
          )
          @ IN NS ns1.mjones.org.
          ns1 IN A 192.0.2.53
          ns1 IN AAAA 2001:db8::53
        '';
      };

      "ilmarin.net." = {
        dnssec = true;
        data = ''
          ; TODO: replace placeholder records.
          $ORIGIN ilmarin.net.
          $TTL 3600
          @ IN SOA ns1.ilmarin.net. hostmaster.ilmarin.net. (
            2026010101 ; serial
            3600       ; refresh
            900        ; retry
            1209600    ; expire
            3600       ; minimum
          )
          @ IN NS ns1.ilmarin.net.
          ns1 IN A 192.0.2.53
          ns1 IN AAAA 2001:db8::53
        '';
      };

      "vala.xyz." = {
        dnssec = true;
        data = ''
          ; TODO: replace placeholder records.
          $ORIGIN vala.xyz.
          $TTL 3600
          @ IN SOA ns1.vala.xyz. hostmaster.vala.xyz. (
            2026010101 ; serial
            3600       ; refresh
            900        ; retry
            1209600    ; expire
            3600       ; minimum
          )
          @ IN NS ns1.vala.xyz.
          ns1 IN A 192.0.2.53
          ns1 IN AAAA 2001:db8::53
        '';
      };

      "movq.uk." = {
        dnssec = true;
        data = ''
          ; TODO: replace placeholder records.
          $ORIGIN movq.uk.
          $TTL 3600
          @ IN SOA ns1.movq.uk. hostmaster.movq.uk. (
            2026010101 ; serial
            3600       ; refresh
            900        ; retry
            1209600    ; expire
            3600       ; minimum
          )
          @ IN NS ns1.movq.uk.
          ns1 IN A 192.0.2.53
          ns1 IN AAAA 2001:db8::53
        '';
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/nsd/acme-challenges 0750 root nsd - -"
  ];

  systemd.services.uacme-renew = {
    description = "Renew ACME certificates with uacme";
    after = [ "network-online.target" "nsd.service" ];
    wants = [ "network-online.target" "nsd.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      set -euo pipefail

      changed=0

      issue_cert() {
        local rc
        set +e
        ${pkgs.uacme}/bin/uacme -c /var/lib/uacme -h ${uacmeDnsHook} issue "$@"
        rc=$?
        set -e

        case "$rc" in
          0)
            changed=1
            ;;
          1)
            ;;
          *)
            echo "uacme issue failed for $1 (exit $rc)" >&2
            return "$rc"
            ;;
        esac
      }

      issue_cert mjones.io '*.mjones.io'
      issue_cert ilmarin.net '*.ilmarin.net'

      if [ "$changed" -eq 1 ]; then
        ${pkgs.systemd}/bin/systemctl reload nginx.service
      fi
    '';
  };

  systemd.timers.uacme-renew = {
    description = "Periodic ACME certificate renewal";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Persistent = true;
      Unit = "uacme-renew.service";
    };
  };
}
