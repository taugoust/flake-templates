{
  description = "Lean 4 Hello World";

  inputs = {
    nixpkgs.follows = "lean4-nix/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    lean4-nix.url = "github:lenianiva/lean4-nix";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      lean4-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        {
          system,
          pkgs,
          self',
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (lean4-nix.readToolchainFile ./lean-toolchain)
              (
                final: prev:
                nixpkgs.lib.optionalAttrs prev.stdenv.isDarwin {
                  # Keep upstream's relative dylib paths: rewriting them to store
                  # paths exceeds the Mach-O header space in the binary release.
                  lean =
                    let
                      toolchain = final.callPackage "${lean4-nix}/lib/toolchain.nix" {
                        stdenv = prev.stdenv // {
                          mkDerivation =
                            args:
                            prev.stdenv.mkDerivation (
                              args
                              // {
                                dontStrip = true;
                                nativeBuildInputs = builtins.filter (input: input != prev.fixDarwinDylibNames) (
                                  args.nativeBuildInputs or [ ]
                                );
                              }
                            );
                        };
                      };
                      tag = nixpkgs.lib.removePrefix "leanprover/lean4:" (
                        nixpkgs.lib.trim (builtins.readFile ./lean-toolchain)
                      );
                    in
                    toolchain.fetchBinaryLean (import "${lean4-nix}/manifests/${tag}.nix");
                }
              )
            ];
          };

          packages.default =
            (pkgs.lean.buildLeanPackage {
              name = "hello";
              roots = [ "Main" ];
              src = pkgs.lib.cleanSource ./.;
              linkFlags = pkgs.lib.optionals pkgs.stdenv.isDarwin [
                "-Wl,-rpath,${pkgs.lean.lean-all}/lib/lean"
              ];
            }).executable;

          checks.hello =
            pkgs.runCommand "lean-hello-check"
              {
                nativeBuildInputs = [
                  pkgs.lean.lean-all
                  pkgs.stdenv.cc
                ];
              }
              ''
                export HOME="$TMPDIR"
                cp ${./Main.lean} Main.lean
                cp ${./lakefile.toml} lakefile.toml
                cp ${./lake-manifest.json} lake-manifest.json
                cp ${./lean-toolchain} lean-toolchain

                test "$(${self'.packages.default}/bin/hello)" = "Hello, world!"
                lake build
                test "$(lake exe hello)" = "Hello, world!"
                touch "$out"
              '';

          devShells.default = pkgs.mkShell {
            packages = with pkgs.lean; [ lean-all ];
          };
        };
    };
}
