{
  inputs = {
    nixpkgs = {
      url = "https://git.mjones.io/mike/nixpkgs/archive/master.tar.gz";
    };
    lct = {
      url = "tarball+https://git.mjones.io/mike/lct/archive/master.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, lct, ... }:
    let
      system = "x86_64-linux";
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

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nixOverlay ];
      };

      lctPkg = lct.packages.${system}.default;

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
        python3
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
      ];
    in {
      overlays.default = nixOverlay;
      packages.${system}.default = pkgs.buildEnv {
        name = "user-profile";
        paths = myPackages;
        pathsToLink = [ "/bin" "/lib" "/share" "/etc" ];
        extraOutputsToInstall = [ "man" "doc" "info" "devdoc" ];
        ignoreCollisions = true;
      };
    };
}
