{
  inputs = {
    nixpkgs.url = "tarball+https://git.mjones.io/mike/nixpkgs/archive/master.tar.gz";
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations.hel1-1 = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
      ];
    };
  };
}
