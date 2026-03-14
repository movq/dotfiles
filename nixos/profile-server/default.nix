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
    binutils
    compsize
    python3
    wireguard-tools
    tmux
    delta
    file
    unzip
    fzf
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
