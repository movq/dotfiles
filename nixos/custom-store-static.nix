let
  pkgs = import <nixpkgs> {};
  commonFlags = [
    "-Dsysconfdir=/home/jom9cbg/nix/etc"
    "-Dlocalstatedir=/home/jom9cbg/nix/var"
  ];
in
pkgs.pkgsStatic.nixVersions.latest.overrideScope (_: nixPrev: {
  nix-store = nixPrev.nix-store.overrideAttrs (old: {
    mesonFlags = (old.mesonFlags or [ ]) ++ commonFlags ++ [
      "-Dstore-dir=/home/jom9cbg/nix/store"
      "-Dlog-dir=/home/jom9cbg/nix/var/log"
    ];
  });
  nix-cli = nixPrev.nix-cli.overrideAttrs (old: {
    mesonFlags = (old.mesonFlags or [ ]) ++ commonFlags;
  });
})
