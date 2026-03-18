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

    customNix = prev.nixVersions.stable.overrideScope (_: nixPrev: {
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

  myPackages = with pkgs; [
    fish
    git
    curl
    jq
    ripgrep
    fd
    htop
    neovim
    jujutsu
    tmux
    delta
    file
    unzip
    fzf
    ncurses
    uv
    glibcLocales
  ];
in
  pkgs.buildEnv {
    name = "user-profile";
    paths = myPackages;
    pathsToLink = [ "/bin" "/lib" "/share" "/etc" ];
    extraOutputsToInstall = [ "man" "doc" "info" "devdoc" ];
    ignoreCollisions = true;
  }
