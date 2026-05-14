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
    in {
      packages.${system}.default = import ./. { inherit pkgs; };
    };
}
