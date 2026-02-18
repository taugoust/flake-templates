{
  description = "Nix Flake Templates";

  outputs = { ... }: {
    templates = {
      nix-develop.path = ./nix-develop;
    };
  };
}
