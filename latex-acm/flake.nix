{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-basic

            # tooling
            latexmk
            latex-bin

            # document class
            acmart

            # acmart dependencies
            lm
            url
            cmap
            float
            iftex
            newtx
            xcolor
            natbib
            comment
            upquote
            environ
            caption
            xstring
            xkeyval
            ifmtarg
            booktabs
            hyperref
            totpages
            textcase
            everyshi
            hyperxmp
            setspace
            ncctools
            preprint
            geometry
            microtype
            pdfescape
            libertine
            inconsolata
            ;
        };
      in
      {
        formatter = pkgs.nixfmt;

        packages.default = pkgs.stdenvNoCC.mkDerivation rec {
          name = "paper";

          src = self;

          buildInputs = [
            tex
            pkgs.coreutils
            pkgs.libertine
            pkgs.inconsolata
          ];

          phases = [
            "unpackPhase"
            "buildPhase"
            "installPhase"
          ];

          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            mkdir -p .cache/texmf-var
            env TEXMFHOME=$TMPDIR TEXMFVAR=$TMPDIR/texmf-var latexmk -interaction=nonstopmode \
                -silent -pdf main.tex || { cat main.log; exit 1; }
            '';

          installPhase = ''
              mkdir -p $out
              cp main.pdf $out/
          '';
        };

        apps.default = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "open-pdf" ''
              exec ${pkgs.xdg-utils}/bin/xdg-open ${self.packages.${system}.default}/main.pdf
            ''
          );
        };

        devShells.default = pkgs.mkShell {
          shellHook = ''
            export TEXMFHOME=$PWD/.cache/texmf-home
            export TEXMFVAR=$PWD/.cache/texmf-var
            mkdir -p "$TEXMFVAR"
          '';
          packages = [
            tex
            pkgs.bibtool
          ];
        };
      }
    );
}
