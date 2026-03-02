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

