let overlay = final: prev: {
};
in
{
  pkgs ? import <nixpkgs> { overlays = [ ]; },
}:
let
  lctPkg = import (builtins.fetchTarball {
    url = https://git.mjones.io/mike/lct/archive/b7a1df6d6b9e552f6e8f8872199fa5a2fc42c715.tar.gz;
    sha256 = "0x92jqljdj5q6b494viqzzq7awispp5nq45fznbwrm86wlggnhdk";
  }) { inherit pkgs; };

  myPackages = with pkgs; [
    android-tools
    bash
    bees
    bind.dnsutils
    binutils
    btrfs-progs
    bubblewrap
    compsize
    coreutils
    curl
    dejavu_fonts
    delta
    e2fsprogs
    fd
    ffmpegthumbnailer
    file
    fish
    fontconfig
    foot
    fuzzel
    fzf
    gawk
    git
    gnugrep
    gnused
    gnutar
    grub2
    grub2_efi
    gsettings-desktop-schemas
    htop
    i3status
    imv
    jq
    jujutsu
    lctPkg
    less
    librewolf
    mandoc
    mpv
    mtools
    ncpamixer
    neovim
    noto-fonts-lgc-plus
    openssh
    OVMF.fd
    papirus-icon-theme
    pcmanfm-qt
    pipewire
    pv
    python3
    qbittorrent
    qemu
    qt6Packages.qt6ct
    qt6Packages.qtstyleplugin-kvantum
    rclone
    ripgrep
    sox
    sway
    swtpm
    tmux
    tokei
    unzip
    util-linux
    wireguard-tools
    wireplumber
    wl-clipboard
    wlsunset
  ];
in
  pkgs.buildEnv {
    name = "user-profile";
    paths = myPackages;
    pathsToLink = [ "/bin" "/lib" "/share" "/etc" ];
    extraOutputsToInstall = [ "man" "doc" "info" "devdoc" ];
    ignoreCollisions = true;
  }
