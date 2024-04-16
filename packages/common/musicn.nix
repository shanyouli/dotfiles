{
  lib,
  stdenv,
  source,
  stdenvNoCC,
  jq,
  moreutils,
  nodePackages,
  cacert,
  makeWrapper,
  python3,
  npmHooks,
  patchelf,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;

  pnpmDeps = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-pnpm-deps";
    inherit (finalAttrs) src version;

    nativeBuildInputs = [jq moreutils nodePackages.pnpm cacert];

    installPhase = ''
      export HOME=$(mktemp -d)

      pnpm config set store-dir $out
      pnpm install --frozen-lockfile --ignore-script

      rm -rf $out/v3/tmp
      for f in $(find $out -name "*.json"); do
        sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
        jq --sort-keys . $f | sponge $f
      done
    '';

    dontBuild = true;
    dontFixup = true;
    outputHashMode = "recursive";
    outputHash =
      {
        x86_64-linux = "sha256-w/xrPRWFqJFsnDuAwXjwLdclwBv2sv1VU2OcdMcfvNs=";
        aarch64-linux = "sha256-w/xrPRWFqJFsnDuAwXjwLdclwBv2sv1VU2OcdMcfvNs=";
        x86_64-darwin = "sha256-w/xrPRWFqJFsnDuAwXjwLdclwBv2sv1VU2OcdMcfvNs=";
        aarch64-darwin = "sha256-w/xrPRWFqJFsnDuAwXjwLdclwBv2sv1VU2OcdMcfvNs=";
      }
      .${stdenv.system}
      or (throw "Unsupported system: ${stdenv.system}");
  };
  nativeBuildInputs = [makeWrapper python3 nodePackages.pnpm nodePackages.nodejs npmHooks.npmInstallHook patchelf];
  preBuild = ''
    export HOME=$(mktemp -d)
    export STORE_PATH=$(mktemp -d)

    cp -Tr "$pnpmDeps" "$STORE_PATH"
    chmod -R +w "$STORE_PATH"

    pnpm config set store-dir "$STORE_PATH"
    pnpm install --offline --frozen-lockfile --ignore-script
    patchShebangs node_modules/{*,.*}
    ls
  '';
  postBuild = ''
    pnpm rebuild
    pnpm build
  '';
  # postInstall = ''
  #   tree
  #   tree $out/
  # '';
  passthru = {
    inherit (finalAttrs) pnpmDeps;
  };
  dontNpmPrune = true;
  dontStrip = true;
  meta = with lib; {
    description = "🎵 一个可播放及下载音乐的 Node.js 命令行工具 ";
    homepage = "https://github.com/zonemeen/musicn";
    license = licenses.mit;
    maintainers = with maintainers; [shanyouli];
  };
})
