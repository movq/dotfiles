{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    # NOTE: 'nixos' is the default hostname
    nixosConfigurations.sv1 = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
  };
}

