{
  description = "Rust project using crane";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane.url = "github:ipetkov/crane";

    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      crane,
      advisory-db,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      perSystem = lib.genAttrs lib.systems.flakeExposed (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          craneLib = crane.mkLib pkgs;

          src = craneLib.cleanCargoSource ./.;
          commonArgs = {
            inherit src;
            strictDeps = true;
            buildInputs = lib.optionals pkgs.stdenv.isDarwin [ pkgs.libiconv ];
          };
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;

          my-crate = craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });
        in
        {
          packages.default = my-crate;

          apps.default = {
            type = "app";
            program = lib.getExe my-crate;
          };

          checks = {
            inherit my-crate;

            my-crate-clippy = craneLib.cargoClippy (
              commonArgs
              // {
                inherit cargoArtifacts;
                cargoClippyExtraArgs = "--all-targets -- --deny warnings";
              }
            );

            my-crate-doc = craneLib.cargoDoc (
              commonArgs
              // {
                inherit cargoArtifacts;
                env.RUSTDOCFLAGS = "--deny warnings";
              }
            );

            my-crate-fmt = craneLib.cargoFmt { inherit src; };

            my-crate-toml-fmt = craneLib.taploFmt {
              src = pkgs.lib.sources.sourceFilesBySuffices src [ ".toml" ];
            };

            my-crate-audit = craneLib.cargoAudit { inherit src advisory-db; };

            my-crate-deny = craneLib.cargoDeny { inherit src; };

            my-crate-nextest = craneLib.cargoNextest (
              commonArgs
              // {
                inherit cargoArtifacts;
                partitions = 1;
                partitionType = "count";
                cargoNextestPartitionsExtraArgs = "--no-tests=pass";
              }
            );
          };

          devShells.default = craneLib.devShell {
            checks = self.checks.${system};
            packages = [
              # pkgs.ripgrep
            ];
          };
        }
      );
    in
    {
      packages = lib.mapAttrs (_: s: s.packages) perSystem;
      apps = lib.mapAttrs (_: s: s.apps) perSystem;
      checks = lib.mapAttrs (_: s: s.checks) perSystem;
      devShells = lib.mapAttrs (_: s: s.devShells) perSystem;
    };
}
