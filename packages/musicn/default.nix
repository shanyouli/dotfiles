{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodePackages,
  python3,
}:
buildNpmPackage rec {
  pname = "musicn";
  version = "1.4.64";

  src = fetchFromGitHub {
    owner = "zonemeen";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-mx0ElreuHZULdvgEfCxRgOeFDLtlvUTdIU3XaC3deuc=";
  };

  npmDepsHash = "sha256-jsyOJr7nm95CYJa/NW2X5p0JP56TX5cnYmPONl/xD/I=";

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
