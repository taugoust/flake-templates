{
  description = "A minimal Quint hello-world project";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          quint-language-server = pkgs.callPackage ./nix/quint-language-server.nix { };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.quint
              self.packages.${system}.quint-language-server
            ];
          };
        }
      );

      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          hello = pkgs.writeShellScript "quint-hello" ''
            exec ${pkgs.quint}/bin/quint run ${./hello.qnt} \
              --backend=typescript --invariant=validGreeting \
              --max-samples=1 --max-steps=3 --seed=1 "$@"
          '';
        in
        {
          default = {
            type = "app";
            program = "${hello}";
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          language-server =
            pkgs.runCommand "quint-language-server-check"
              {
                nativeBuildInputs = [
                  self.packages.${system}.quint-language-server
                  pkgs.python3
                ];
              }
              ''
                export HOME="$TMPDIR"
                python3 ${./tests/lsp-smoke.py} ${./hello.qnt}
                touch "$out"
              '';

          hello =
            pkgs.runCommand "quint-hello-check"
              {
                nativeBuildInputs = [ pkgs.quint ];
              }
              ''
                quint typecheck ${./hello.qnt}
                quint run ${./hello.qnt} --backend=typescript --invariant=validGreeting --max-samples=10 --max-steps=5 --seed=1
                touch "$out"
              '';
        }
      );
    };
}
