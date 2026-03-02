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
    };
  };
}
