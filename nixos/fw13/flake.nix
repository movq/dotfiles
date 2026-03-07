{
  inputs = {
    nixpkgs.url = "github:movq/nixpkgs/full-source-bootstrap";
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations.mike-framework = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
  };
}
