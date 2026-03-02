# Nix Flake Templates

This repository contains nix flake templates for different types of projects.

## Templates

### `nix-develop`

A generic development shell.

```sh
nix flake init --template github:taugoust/flake-templates#nix-develop
```

### `python`

A Python project using [uv2nix](https://github.com/pyproject-nix/uv2nix), with a dev shell
(editable installs, all dependency groups) and a production package (virtualenv).

```sh
nix flake init --template github:taugoust/flake-templates#python
```

Extend `pyprojectOverrides` in the flake when a dependency needs extra build-system inputs
(e.g. `setuptools` for packages that don't declare it properly).

### `rust`

A Rust project using [crane](https://github.com/ipetkov/crane), with a package, app, dev shell,
and a full suite of checks: clippy, rustfmt, taplo (TOML fmt), rustdoc, cargo-audit, cargo-deny,
and cargo-nextest.

```sh
nix flake init --template github:taugoust/flake-templates#rust
```

### `ocaml`

An OCaml project using [opam-nix](https://github.com/tweag/opam-nix) with `buildDuneProject` and
a pinned `opam-repository`, with a package and dev shell (`ocaml-lsp-server`, `ocamlformat`,
`utop`).

```sh
nix flake init --template github:taugoust/flake-templates#ocaml
```

Set `package` to your opam package name, and extend the `overlay` for any dependencies that need
build-system fixes.

### `haskell`

A Haskell project using [cabal2nix](https://github.com/NixOS/cabal2nix) (`callCabal2nix`), with a
package and dev shell (`cabal-install`, `haskell-language-server`, `ghcid`, Hoogle).

```sh
nix flake init --template github:taugoust/flake-templates#haskell
```

Set `package` to your `.cabal` package name. Override `haskellPackages` with `doJailbreak` /
`dontCheck` as needed, or swap `pkgs.haskellPackages` for `pkgs.haskell.packages.ghc9XX` to pin a
specific GHC version.

### `isabelle`

An Isabelle theory development environment. Builds all sessions declared in `ROOT` files via
`isabelle build -D .`, capturing browser info as output. `packages.default` and `checks.default`
both point to the same derivation — running `nix flake check` verifies the theories.

```sh
nix flake init --template github:taugoust/flake-templates#isabelle
```

