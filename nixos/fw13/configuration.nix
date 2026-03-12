{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2ccc0c18-b649-49ae-bc5c-618de8bbb3d5";
      fsType = "btrfs";
      options = [ "subvol=/nixos" "compress-force=zstd:3" ];
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/454A-A115";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/2ccc0c18-b649-49ae-bc5c-618de8bbb3d5";
      fsType = "btrfs";
      options = [ "subvol=/home" "compress-force=zstd:3" ];
    };
  fileSystems."/mnt/rootvol" =
    { device = "/dev/disk/by-uuid/2ccc0c18-b649-49ae-bc5c-618de8bbb3d5";
      fsType = "btrfs";
      options = [ "subvol=/" "compress-force=zstd:3" ];
    };

  swapDevices = [ {
    device = "/mnt/rootvol/swap/swapfile";
  } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "mitigations=off" "amdgpu.dcdebugmask=0x10" "resume_offset=13378816" ];
  boot.resumeDevice = "/dev/disk/by-uuid/2ccc0c18-b649-49ae-bc5c-618de8bbb3d5";

  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/00814310-5bec-41f7-a265-fe6b9e3690d8";

  security.sudo.wheelNeedsPassword = false;
  security.doas.enable = true;
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    # Optional, retains environment variables while running commands
    # e.g. retains your NIX_PATH when applying your config
    keepEnv = true;
    noPass = true;
  }];

  nix.package = pkgs.nixVersions.latest;
  nix.settings = {
    substituters = lib.mkForce [ "https://nix-cache.mjones.io" ];
    trusted-public-keys = lib.mkForce [ "nix-cache.mjones.io:tOio4xRDNRMH4PfvWIS9lDa32ynJGZt1naEVDg5u+nU=" ];
    trusted-users = [ "mike" "@wheel" ];
    use-registries = false;
    extra-experimental-features = [ "nix-command" "flakes" ];
    builders-use-substitutes = true;
  };

  networking.hostName = "mike-framework"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak-uk";
  #   useXkbConfig = true; # use xkb.options in tty.
  };

  hardware.bluetooth.enable = true;

  users.extraGroups.mike.gid = 1000;
  users.users.mike = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    uid = 1000;
    group = "mike";
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.openssh.enable = true;

  hardware.graphics.enable = true;

  system.stateVersion = "25.05";
}

