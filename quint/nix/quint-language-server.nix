{
  lib,
  buildNpmPackage,
  quint,
}:

buildNpmPackage {
  pname = "quint-language-server";
  version = "0.20.0";

  # Build the server from the same pinned upstream release as the Quint CLI.
  inherit (quint) src;
  sourceRoot = "${quint.src.name}/vscode/quint-vscode/server";
  npmDepsHash = "sha256-Y0p5mYc8JsjnsBz0MQCEZl41NoDQeq/zAwxNJBRA4fI=";
  npmBuildScript = "compile";

  # Upstream imports this protocol type from the VS Code client, which is
  # available in the extension workspace but not the standalone server.
  postPatch = ''
    substituteInPlace src/complete.ts \
      --replace-fail "from 'vscode-languageclient'" "from 'vscode-languageserver'"
  '';

  meta = {
    description = "Language server for the Quint specification language";
    homepage = "https://github.com/quint-co/quint";
    license = lib.licenses.asl20;
    mainProgram = "quint-language-server";
    platforms = lib.platforms.unix;
  };
}
