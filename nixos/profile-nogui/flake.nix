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
      pkgs = nixpkgs.legacyPackages.${system};
      lctPkg = lct.packages.${system}.default;  # adjust based on how lct exposes its package

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
      ];
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "user-profile";
        paths = myPackages;
        pathsToLink = [ "/bin" "/lib" "/share" "/etc" ];
        extraOutputsToInstall = [ "man" "doc" "info" "devdoc" ];
        ignoreCollisions = true;
      };
    };
}
