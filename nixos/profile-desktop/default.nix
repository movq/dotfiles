{
  pkgs ? import <nixpkgs> {},
}:
let
  lctPkg = import (builtins.fetchTarball {
    url = https://git.mjones.io/mike/lct/archive/8d0967ffbc61442f8e45da761a925460ec02701a.tar.gz;
    sha256 = "1cd30fwc0qpyvyc9slv5ry3xzyhkkc1saqp8sss2r38fbwawlpd1";
  }) { inherit pkgs; };

  myPackages = with pkgs; [
    fish
    rclone
    git
    curl
    jq
    ripgrep
    fd
    htop
    neovim
    jujutsu
    lctPkg
    bubblewrap
    ncpamixer
    pcmanfm-qt
    wlsunset
    binutils
    mpv
    imv
    qbittorrent
    librewolf
    i3status
    sox
    compsize
    python3
    fuzzel
    wl-clipboard
    qt6Packages.qtstyleplugin-kvantum
    qt6Packages.qt6ct
    papirus-icon-theme
    noto-fonts-lgc-plus
    wireguard-tools
    ffmpegthumbnailer
    tmux
    delta
    file
    unzip
    fzf
    android-tools
    pv
    bind.dnsutils
  ];
in
  pkgs.buildEnv {
    name = "user-profile";
    paths = myPackages;
    pathsToLink = [ "/bin" "/lib" "/share" "/etc" ];
    extraOutputsToInstall = [ "man" "doc" "info" "devdoc" ];
    ignoreCollisions = true;
  }
