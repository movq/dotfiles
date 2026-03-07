{
  inputs = {
    nixpkgs.url = "github:movq/nixpkgs/full-source-bootstrap";
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations.hel1-1 = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
  };
}
