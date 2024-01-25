{
  lib,
  buildNpmPackage,
  nodePackages,
  python3,
  source,
}:
buildNpmPackage rec {
  inherit (source) pname version src npmDepsHash;

  nativeBuildInputs = [nodePackages.node-gyp python3];
  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  # The prepack script runs the build script, which we'd rather do in the build phase.
  # npmPackFlags = [ "--ignore-scripts" ];

  # NODE_OPTIONS = "--openssl-legacy-provider";

  meta = with lib; {
    description = "🎵 一个可播放及下载音乐的 Node.js 命令行工具 ";
    homepage = "https://github.com/zonemeen/musicn";
    license = licenses.mit;
    maintainers = with maintainers; [shanyouli];
  };
}
