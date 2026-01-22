# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "mitigations=off" ];

  networking = {
    hostName = "sv1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    interfaces.eno1 = {
      ipv6.addresses = [{
        address = "2a01:4f8:120:33e5::1";
        prefixLength = 64;
      }];
      ipv4.addresses = [{
        address = "78.46.77.242";
        prefixLength = 32;
      }];
      ipv4.routes = [
        {
          address = "78.46.77.225";
          prefixLength = 32;
          options.src = "78.46.77.242";
        }
        {
          address = "0.0.0.0";
          prefixLength = 0;
          via = "78.46.77.225";
        }
      ];
    };
#    defaultGateway = {
#      address = "78.46.77.225";
#      interface = "eno1";
#    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eno1";
    };
  };
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraGroups.mike.gid = 1000;
  users.users.mike = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    uid = 1000;
    group = "mike";
  };

  security.sudo.wheelNeedsPassword = false;
  security.doas.enable = true;
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    # Optional, retains environment variables while running commands
    # e.g. retains your NIX_PATH when applying your config
    keepEnv = true;
    noPass = true;
  }];
  nix.settings.trusted-users = [ "root" "mike" "@wheel" ];
  nix.settings.cores = 6;
  nix.settings.max-jobs = 2;

  systemd.oomd.enable = false;

  system.nssModules = lib.mkForce [];
  services.nscd.enable = false;

  services.openssh.enable = true;

  users.users.nginx.extraGroups = [ "acme" ];

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts.localhost = {
      addSSL = true;
      sslCertificate = "/var/lib/acme/self.crt";
      sslCertificateKey = "/var/lib/acme/self.key";
      default = true;
      locations."/" = {
        return = "404";
      };
    };

    virtualHosts."nix-cache.mjones.io" = {
      addSSL = true;
      sslCertificate = "/var/lib/acme/config/live/nix-cache.mjones.io/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/config/live/nix-cache.mjones.io/privkey.pem";
      locations."/key.pub" = {
        extraConfig = "types { text/plain pub; }";
        return = "200 \"nix-cache.mjones.io:UX816pMG0HQgnBSQk7z6zoHio8ZMCFxbXDQol8R1FLU=\\n\"";
      };
      locations."/.well-known/acme-challenge" = {
        root = "/var/lib/acme/nix-cache.mjones.io";
      };
      locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
    };
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cache-priv-key.pem";
    port = 1024;
    bindAddress = "127.0.0.1";
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
