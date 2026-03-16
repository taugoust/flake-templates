{
  description = "Isabelle theory development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      perSystem = lib.genAttrs lib.systems.flakeExposed (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Builds all Isabelle sessions declared in ROOT files under the repo root.
          # HOME and USER must be set because Isabelle writes to ~/.isabelle at build time.
          theories = pkgs.stdenv.mkDerivation {
            name = "isabelle-theories";
            src = ./.;
            buildInputs = [ pkgs.isabelle ];
            buildPhase = ''
              export HOME=$TMPDIR
              export USER=isabelle
              ${pkgs.isabelle}/bin/isabelle build -D . -v
            '';
            installPhase = ''
              mkdir -p $out
              cp -r $HOME/.isabelle/Isabelle*/browser_info $out/ || true
              touch $out/build-success
            '';
          };
        in
        {
          packages.default = theories;
          checks.default = theories;

          devShells.default = pkgs.mkShell {
            packages = [ pkgs.isabelle ];
          };
        }
      );
    in
    {
      packages = lib.mapAttrs (_: s: s.packages) perSystem;
      checks = lib.mapAttrs (_: s: s.checks) perSystem;
      devShells = lib.mapAttrs (_: s: s.devShells) perSystem;
    };
}
