# Lean Hello World

A minimal Lean 4 project based on
[lean4-nix](https://github.com/lenianiva/lean4-nix). Nix provides Lean and Lake;
no separate elan installation is needed.

## Run

```sh
nix run .
# Hello, world!
```

If you initialize a Git repository, stage the generated files before using the
flake so Nix can see them:

```sh
git init
git add .
```

## Develop with Lake

```sh
nix develop
lake build
lake exe hello
# Or interpret the source directly:
lean --run Main.lean
```

Edit `Main.lean` to change the program. The template includes `lakefile.toml`,
`lake-manifest.json`, and `lean-toolchain`. There are no external Lake dependencies.
Lake creates `.lake/` locally; generated build artifacts are not part of the
template and are ignored by Git.

The default Nix package uses lean4-nix's direct Lean builder; it does not read
Lake's build targets or automatically package future Lake dependencies. If you
add targets or dependencies, update the Nix packaging separately.

### Automatic environment with direnv

With direnv and nix-direnv installed and your shell hooked into direnv, run:

```sh
direnv allow
```

Direnv loads the development shell when you enter this directory and unloads it
when you leave. Open your configured editor from this environment to use the
project's Lean toolchain. The generated `.direnv/` cache is ignored by Git.

## Build and validate

```sh
nix build
./result/bin/hello
nix flake check
```

The check builds and runs the Nix executable, then builds and runs the Lake
project in a clean Nix sandbox, checking the hello-world output from both.

`lean-toolchain` selects Lean 4.35.0. `flake.lock` pins the Nix inputs, with
nixpkgs following lean4-nix's version. Update these together: lean4-nix must
support the version requested by `lean-toolchain`.

## macOS compatibility

The pinned upstream binary packaging fails when rewriting Darwin dylib names,
and stripping the release libraries produces invalid Mach-O load commands.
The Darwin-only overlay in `flake.nix` disables these operations for the binary
toolchain, preserving its relative library paths. The Nix-built executable also
gets an explicit runtime library search path.

The workaround imports internal lean4-nix files, so revalidate it when updating
the flake lock. Lake may emit linker warnings because bundled libraries target
macOS 15 while the Nix compiler defaults to macOS 14. Other platforms are
included in the flake but have not been tested.
