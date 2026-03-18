{
  pkgsFun ? import <nixpkgs>,
  system ? builtins.currentSystem,
}:
let
  nixOverlay = _final: prev:
  let
    commonFlags = [
      "-Dsysconfdir=/home/jom9cbg/nix/etc"
      "-Dlocalstatedir=/home/jom9cbg/nix/var"
    ];

    customNix = prev.nixVersions.latest.overrideScope (_: nixPrev: {
      nix-store = nixPrev.nix-store.overrideAttrs (old: {
        mesonFlags = (old.mesonFlags or [ ]) ++ commonFlags ++ [
          "-Dstore-dir=/home/jom9cbg/nix/store"
          "-Dlog-dir=/home/jom9cbg/nix/var/log"
        ];
      });
      nix-cli = nixPrev.nix-cli.overrideAttrs (old: {
        mesonFlags = (old.mesonFlags or [ ]) ++ commonFlags;
      });
    });
  in {
    nix = customNix;
};

  pkgs = pkgsFun {
    inherit system;
    overlays = [ nixOverlay ];
  };

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
    binutils
    sox
    compsize
    (python3.withPackages (ps: [ ps.pygobject3 ]))
    tmux
    delta
    file
    unzip
    fzf
    nix
    pipewire
    wireplumber
    ncurses
    glibc
    uv
    ty
    sway
    fuzzel
    foot
    i3status
    glibcLocales
    grim
    slurp
    librewolf
    llvmPackages.clang-tools
  ];
in
  pkgs.buildEnv {
    name = "user-profile";
    paths = myPackages;
    pathsToLink = [ "/bin" "/lib" "/share" "/etc" ];
    extraOutputsToInstall = [ "man" "doc" "info" "devdoc" ];
    ignoreCollisions = true;
  }
