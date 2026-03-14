{
  inputs = {
    nixpkgs = {
      url = "tarball+https://git.mjones.io/mike/nixpkgs/archive/master.tar.gz";
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
      ];
    in {
      packages.${system}.default = import ./. { inherit pkgs; };
    };
}
