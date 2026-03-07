{
  inputs = {
    nixpkgs = {
      url = "github:movq/nixpkgs/full-source-bootstrap";
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
