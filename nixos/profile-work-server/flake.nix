{
  inputs = {
    nixpkgs = {
      url = "https://git.mjones.io/mike/nixpkgs/archive/master.tar.gz";
    };
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgsFun = import nixpkgs;
      profile = import ./. { inherit pkgsFun system; };

    in {
      packages.${system}.default = profile;
    };
}
