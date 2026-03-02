{
  description = "Nix Flake Templates";

  outputs = { ... }: {
    templates = {
      nix-develop = {
        path = ./nix-develop;
        description = "Generic development shell";
      };
      python = {
        path = ./python;
        description = "Python project using uv2nix (dev shell + package)";
      };
      rust = {
        path = ./rust;
        description = "Rust project using crane (package, app, checks, dev shell)";
      };
      ocaml = {
        path = ./ocaml;
        description = "OCaml project using opam-nix (package, dev shell)";
      };
    };
  };
}
