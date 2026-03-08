{
  inputs = {
    nixpkgs.url = "https://git.mjones.io/mike/nixpkgs/archive/master.tar.gz";
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations.mike-alienware = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
  };
}
