{
  description = "OCaml project using opam-nix";

  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    nixpkgs.follows = "opam-nix/nixpkgs";
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      opam-nix,
      opam-repository,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # The opam package name, as declared in your .opam / dune-project file.
      package = "my-package";

      # Packages added to the dev shell but not to the production build.
      devPackagesQuery = {
        ocaml-lsp-server = "*";
        ocamlformat = "*";
        utop = "*";
      };

      query = devPackagesQuery // {
        ocaml-base-compiler = "*";
      };

      perSystem = lib.genAttrs lib.systems.flakeExposed (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          on = opam-nix.lib.${system};

          scope = on.buildDuneProject { repos = [ opam-repository ]; } package ./. query;

          overlay = final: prev: {
            # Prevent OCaml build deps from leaking into downstream environments.
            ${package} = prev.${package}.overrideAttrs (_: {
              doNixSupport = false;
            });
            # Add further overrides here if needed.
          };

          resolvedScope = scope.overrideScope overlay;
          main = resolvedScope.${package};
          devPackages = builtins.attrValues (lib.getAttrs (builtins.attrNames devPackagesQuery) resolvedScope);
        in
        {
          legacyPackages = resolvedScope;

          packages.default = main;

          devShells.default = pkgs.mkShell {
            inputsFrom = [ main ];
            buildInputs = devPackages;
          };
        }
      );
    in
    {
      legacyPackages = lib.mapAttrs (_: s: s.legacyPackages) perSystem;
      packages = lib.mapAttrs (_: s: s.packages) perSystem;
      devShells = lib.mapAttrs (_: s: s.devShells) perSystem;
    };
}
