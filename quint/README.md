# Hello, Quint

A minimal [Quint](https://quint.sh/docs/getting-started) specification with a
locked Nix development environment. Requires Nix with flakes enabled.

## Run

```sh
nix run
nix flake check
```

The trace starts with `greeting = "Hello"`, then transitions to
`greeting = "Hello, world!"`. Subsequent steps keep that greeting.
`validGreeting` asserts that the state always contains one of those two values.
Quint models state transitions; this is not a program that prints a message.

The TypeScript simulator is selected explicitly for a lightweight, portable
example. Simulation checks sampled executions, not an exhaustive proof.
Extra Quint options can be passed with `nix run . -- --verbosity=3`.

If you initialize a Git repository, stage the generated files before using the
flake so Nix can see them:

```sh
git init
git add .
```

## Development shell and direnv

```sh
nix develop
quint --version
quint typecheck hello.qnt
quint run hello.qnt --backend=typescript --invariant=validGreeting
```

With direnv and nix-direnv installed and your shell hooked into direnv, run
`direnv allow` once in this directory. It will load the development environment
automatically when you enter the directory.

## Editor support

The shell provides `quint-language-server --stdio`, built from the same pinned
upstream source release as the CLI, with upstream's locked npm dependencies.
Configure your editor to use it for `.qnt` files. No packages are installed
globally by this template.

For Neovim 0.11+, the following Lua registers the filetype and server:

```lua
vim.filetype.add({ extension = { qnt = 'quint' } })
vim.lsp.config('quint', {
  cmd = { 'quint-language-server', '--stdio' },
  filetypes = { 'quint' },
  root_markers = { 'flake.nix', '.git' },
})
vim.lsp.enable('quint')
```

The language server does **not** provide syntax highlighting. Install upstream's
[`quint.vim`](https://github.com/quint-co/quint/blob/v0.33.0/editor-plugins/vim/quint.vim)
as `syntax/quint.vim` on Neovim's runtime path (for example via your Nixvim
`extraFiles` configuration).

Launch your configured editor from the direnv-enabled directory, or run:

```sh
nix develop --command nvim hello.qnt
```

For a Neovim configured as above, including the syntax file, this optional test
checks highlighting, attachment, root detection, and live diagnostics without
changing the specification on disk:

```sh
nix develop --command nvim --headless '+luafile tests/nvim-lsp-smoke.lua'
```

Neovim itself is not included in this template's development shell.

## Checks and updates

`nix flake check` typechecks the specification, runs a seeded simulation checking
the invariant, and exercises language-server initialization, diagnostics, edits,
document symbols, and shutdown over stdio. These checks do not require an editor.

`flake.lock` pins the toolchain. To update it intentionally, run
`nix flake update`, then rerun `nix flake check`. When Quint's upstream release
changes, also review `nix/quint-language-server.nix` for the server version,
source layout, patch, and npm dependency hash.
