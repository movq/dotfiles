{
  pkgs ? import <nixpkgs> {},
}:
let
  lctPkg = import (builtins.fetchTarball {
    url = https://git.mjones.io/mike/lct/archive/master.tar.gz;
    sha256 = "1xsscyikx2jxc3ca34ll5vdl4bw7rd9gqcv81l12c56mrmzckbr4";
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
