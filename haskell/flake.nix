{
  description = "Haskell project using cabal2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      # The package name, as declared in your .cabal file.
      package = "my-package";

      perSystem = lib.genAttrs lib.systems.flakeExposed (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Use pkgs.haskell.packages.ghc9XX to pin a specific GHC version.
          haskellPackages = pkgs.haskellPackages.override {
            overrides = _self: _super: {
              # Add package overrides here. Examples:
              #   some-package = pkgs.haskell.lib.doJailbreak super.some-package;
              #   other-package = pkgs.haskell.lib.dontCheck super.other-package;
            };
          };

          my-package = haskellPackages.callCabal2nix package ./. { };
        in
        {
          packages.default = my-package;

          devShells.default = haskellPackages.shellFor {
            packages = _: [ my-package ];
            nativeBuildInputs = with haskellPackages; [
              cabal-install
              haskell-language-server
              ghcid
            ];
            withHoogle = true;
          };
        }
      );
    in
    {
      packages = lib.mapAttrs (_: s: s.packages) perSystem;
      devShells = lib.mapAttrs (_: s: s.devShells) perSystem;
    };
}
