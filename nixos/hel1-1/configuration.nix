{ config, lib, pkgs, ... }:

let
  # Add or update certificate sets here.
  uacmeCertificates = [
    {
      certName = "mjones.io";
      domains = [ "mjones.io" "*.mjones.io" ];
    }
    {
      certName = "ilmarin.net";
      domains = [ "ilmarin.net" "*.ilmarin.net" ];
    }
  ];

  uacmeIssueArgs = cert:
    lib.concatStringsSep " " (builtins.map lib.escapeShellArg cert.domains);
in
{
  boot.initrd.availableKernelModules = [ "nvme" "ahci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "mitigations=off" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c2785634-d1f7-4195-aedc-a7b372483f9f";
      fsType = "btrfs";
      options = [ "subvol=/nixos" "compress-force=zstd:3" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/75bdb730-422a-41b9-bf6f-b4953e610e23";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/c2785634-d1f7-4195-aedc-a7b372483f9f";
      fsType = "btrfs";
      options = [ "subvol=/home" "compress-force=zstd:3" ];
    };

  fileSystems."/mnt/rootvol" =
    { device = "/dev/disk/by-uuid/c2785634-d1f7-4195-aedc-a7b372483f9f";
      fsType = "btrfs";
      options = [ "subvol=/" "compress-force=zstd:3" ];
    };

  swapDevices = [ ];

  networking = {
    hostName = "hel1-1";
    useDHCP = false;

    interfaces.enp35s0 = {
      ipv4.addresses = [{
        address = "135.181.178.34";
        prefixLength = 26;
      }];
      ipv6.addresses = [{
        address = "2a01:4f9:3a:201f::1";
        prefixLength = 64;
      }];
    };

    defaultGateway = {
      address = "135.181.178.1";
      interface = "enp35s0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp35s0";
    };

    nameservers = [ "185.12.64.1" "185.12.64.2" "2a01:4ff:ff00::add:1" "2a01:4ff:ff00::add:2" ];
  };
  networking.firewall.allowedTCPPorts = [ 25 80 143 443 465 587 993 ];

  time.timeZone = "Europe/London";

  users.extraGroups.mike.gid = 1000;
  users.users.mike = {
    isNormalUser = true;
    uid = 1000;
    group = "mike";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
  security.sudo.wheelNeedsPassword = false;
  security.doas.enable = true;
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    keepEnv = true;
    noPass = true;
  }];

  services.openssh = {
    enable = true;
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = false;
    authentication = ''
      local all all peer
    '';
  };

  services.nix-serve = {
    enable = true;
    bindAddress = "127.0.0.1";
    port = 5000;
    secretKeyFile = "/var/cache-priv-key.pem";
  };

  services.postfix = {
    enable = true;
    enableSubmission = true;
    enableSubmissions = true;

    mapFiles = {
      "virtual-domains" = ./mail/postfix-virtual-domains;
      "virtual-aliases" = ./mail/postfix-virtual-aliases;
    };

    settings.main = {
      myhostname = "hel1-1.ilmarin.net";
      mydomain = "ilmarin.net";
      myorigin = "$mydomain";

      virtual_mailbox_domains = [ "hash:/etc/postfix/virtual-domains" ];
      virtual_alias_maps = [ "hash:/etc/postfix/virtual-aliases" ];
      virtual_transport = "lmtp:unix:private/dovecot-lmtp";

      smtpd_relay_restrictions = [
        "permit_mynetworks"
        "permit_sasl_authenticated"
        "reject_unauth_destination"
      ];

      smtpd_tls_security_level = "may";
      smtpd_tls_cert_file = "/var/lib/uacme/ilmarin.net/cert.pem";
      smtpd_tls_key_file = "/var/lib/uacme/private/ilmarin.net/key.pem";

      smtpd_sasl_auth_enable = "yes";
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "private/auth";
    };
  };

  services.dovecot2 = {
    enable = true;
    enableLmtp = true;
    enablePAM = false;

    sslServerCert = "/var/lib/uacme/ilmarin.net/cert.pem";
    sslServerKey = "/var/lib/uacme/private/ilmarin.net/key.pem";

    extraConfig = ''
      passdb {
        driver = passwd-file
        args = username_format=%u /var/lib/dovecot2/passwd
      }

      userdb {
        driver = passwd-file
        args = username_format=%u /var/lib/dovecot2/passwd
      }

      service auth {
        user = root
        unix_listener /var/lib/postfix/queue/private/auth {
          mode = 0660
          user = postfix
          group = postfix
        }
      }

      service lmtp {
        unix_listener /var/lib/postfix/queue/private/dovecot-lmtp {
          mode = 0600
          user = postfix
          group = postfix
        }
      }
    '';
  };

  services.unbound = {
    enable = true;
    # Keep resolver changes scoped; Rspamd is pointed to localhost explicitly.
    resolveLocalQueries = false;
    settings.server.port = 5353;
  };

  services.rspamd = {
    enable = true;
    postfix.enable = true;
    locals."options.inc".text = ''
      dns {
        nameserver = ["127.0.0.1:5353"];
      }
    '';
  };

  systemd.services.rspamd = {
    after = [ "unbound.service" ];
    wants = [ "unbound.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/dovecot2 0750 root root -"
    "f /var/lib/dovecot2/passwd 0600 root root -"
  ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."nix-cache.mjones.io" = {
      forceSSL = true;
      http2 = true;
      sslCertificate = "/var/lib/uacme/mjones.io/cert.pem";
      sslCertificateKey = "/var/lib/uacme/private/mjones.io/key.pem";
      locations."/" = {
        proxyPass = "http://127.0.0.1:5000";
      };
    };
  };

  systemd.services.uacme-mjones-io = {
    description = "Issue/renew configured certificates with uacme";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.bind.dnsutils pkgs.coreutils pkgs.curl pkgs.uacme ];
    serviceConfig.Type = "oneshot";
    script = ''
      export UACME_DIG_CMD=${pkgs.bind.dnsutils}/bin/dig
      updated=0
      failed=0

      ${lib.concatMapStringsSep "\n" (cert: ''
        set +e
        ${pkgs.uacme}/bin/uacme -v -c /var/lib/uacme -h ${./uacme-hook.sh} -t EC -b 256 -p shortlived issue ${uacmeIssueArgs cert}
        cert_rc=$?
        set -e
        case "$cert_rc" in
          0) updated=1 ;;
          1) ;;
          *) failed=1 ;;
        esac
      '') uacmeCertificates}

      if [ "$failed" -ne 0 ]; then
        exit 2
      fi

      if [ "$updated" -eq 0 ]; then
        exit 1
      fi

      chgrp ${config.services.nginx.group} /var/lib/uacme/private
      chmod 0710 /var/lib/uacme/private

      ${lib.concatMapStringsSep "\n" (cert: ''
        chgrp ${config.services.nginx.group} /var/lib/uacme/private/${cert.certName}
        chmod 0710 /var/lib/uacme/private/${cert.certName}
        chgrp ${config.services.nginx.group} /var/lib/uacme/private/${cert.certName}/key.pem
        chmod 0640 /var/lib/uacme/private/${cert.certName}/key.pem
      '') uacmeCertificates}

      ${pkgs.systemd}/bin/systemctl restart nginx.service
      exit 0
    '';
  };

  systemd.timers.uacme-mjones-io = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  nix.package = pkgs.nixVersions.latest;
  nix.settings = {
    substituters = lib.mkForce [ "https://nix-cache.mjones.io" ];
    trusted-public-keys = lib.mkForce [ "nix-cache.mjones.io:tOio4xRDNRMH4PfvWIS9lDa32ynJGZt1naEVDg5u+nU=" ];
    trusted-users = [ "@wheel" ];
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = 6;
    keep-derivations = true;
    keep-outputs = true;
  };

  system.stateVersion = "26.05";
}
