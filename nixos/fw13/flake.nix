{
  inputs = {
    nixpkgs.url = "tarball+https://git.mjones.io/mike/nixpkgs/archive/master.tar.gz";
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations.mike-framework = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        {
          nixpkgs.hostPlatform = {
            system = "x86_64-linux";
            gcc.arch = "x86-64-v3";
          };
        }
      ];
    };
  };
}
