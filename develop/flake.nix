{
  description = "Development environment for this project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
  flake-utils.lib.eachSystem [ "aarch64-darwin" ] (system:
  let
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    packages.default = pkgs.mkShell {
      packages = with pkgs; [
        bashInteractive
      ]
    };
  });
}
