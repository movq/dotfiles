{ config, lib, pkgs, ... }:

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
  networking.firewall.allowedTCPPorts = [ 80 443 ];

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
    description = "Issue/renew mjones.io certificates with uacme";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.bind.dnsutils pkgs.coreutils pkgs.curl pkgs.uacme ];
    serviceConfig.Type = "oneshot";
    script = ''
      set +e
      export UACME_DIG_CMD=${pkgs.bind.dnsutils}/bin/dig
      ${pkgs.uacme}/bin/uacme -v -c /var/lib/uacme -h ${./uacme-hook.sh} -t EC -b 256 -p shortlived issue mjones.io '*.mjones.io'
      rc=$?
      set -e
      if [ "$rc" -eq 0 ]; then
        ${pkgs.systemd}/bin/systemctl restart nginx.service
      fi
      exit "$rc"
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
  };

  system.stateVersion = "26.05";
}
