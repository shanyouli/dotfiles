{
  lib,
  fetchFromGitHub,
  makeWrapper,
  electron,
  python3,
  stdenv,
  stdenvNoCC,
  copyDesktopItems,
  moreutils,
  cacert,
  jq,
  nodePackages,
  makeDesktopItem,
  source,
  defaultSrc ? true,
}: let
  srcs =
    if defaultSrc
    then rec {
      version = "3.24.41217";
      src = fetchFromGitHub {
        owner = "odomu";
        repo = "aliyunpan";
        rev = "v${version}";
        hash = "sha256-1Y4aiAKopOVstn9Pr44X/46vv8edK8bB6SWoE1pY1Lg=";
      };
      pnpmDepsHash =
        {
          # x86_64-linux = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
          # aarch64-linux = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
          # x86_64-darwin = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
          aarch64-darwin = "sha256-/z8WFwpV+mRolAsWemL9RCiFN2VeT6ftYHPjvqgcINU=";
        }
        .${stdenv.system}
        or (throw "Unsupported system: ${stdenv.system}");
    }
    else {
      inherit (source) src;
      version =
        if (builtins.hasAttr "date" source)
        then source.date
        else lib.removePrefix "v" source.version;
      pnpmDepsHash =
        {
          # x86_64-linux = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
          # aarch64-linux = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
          # x86_64-darwin = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
          aarch64-darwin = "sha256-/z8WFwpV+mRolAsWemL9RCiFN2VeT6ftYHPjvqgcINU=";
        }
        .${stdenv.system}
        or (throw "Unsupported system: ${stdenv.system}");
    };
in
  stdenv.mkDerivation (finalAttrs: {
    inherit (srcs) version src;
    pname = "xbydriver";

    pnpmDeps = stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-pnpm-deps";
      inherit (finalAttrs) src version ELECTRON_SKIP_BINARY_DOWNLOAD;

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
      outputHashAlgo = "sha256";
      outputHash = srcs.pnpmDepsHash;
    };

    nativeBuildInputs =
      [makeWrapper python3 nodePackages.pnpm nodePackages.nodejs]
      ++ lib.optionals (!stdenv.isDarwin) [copyDesktopItems];

    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

    preBuild = ''
      export HOME=$(mktemp -d)
      export STORE_PATH=$(mktemp -d)

      cp -Tr "$pnpmDeps" "$STORE_PATH"
      chmod -R +w "$STORE_PATH"

      pnpm config set store-dir "$STORE_PATH"
      pnpm install --offline --frozen-lockfile --ignore-script
      patchShebangs node_modules/{*,.*}
    '';

    postBuild =
      lib.optionalString stdenv.isDarwin ''
        cp -R ${electron}/Applications/Electron.app Electron.app
        chmod -R u+w Electron.app
      ''
      + ''
        pnpm build
        ./node_modules/.bin/electron-builder \
          --dir \
          -c.electronDist=${
          if stdenv.isDarwin
          then "."
          else "${electron}/libexec/electron"
        } \
          -c.electronVersion=${electron.version}
      '';

    installPhase =
      ''
        runHook preInstall

      ''
      + lib.optionalString stdenv.isDarwin ''
        mkdir -p $out/{Applications,bin}
        # LANG=en_US.utf-8 tree
        mv release/mac*/*.app $out/Applications/
        makeWrapper $out/Applications/*.app/Contents/MacOS/阿里云盘小白羊 $out/bin/${finalAttrs.pname}
      ''
      + lib.optionalString (!stdenv.isDarwin) ''
        mkdir -p "$out/share/lib/${finalAttrs.pname}"
        cp -r release/*-unpacked/{locales,resources{,.pak}} "$out/share/lib/${finalAttrs.pname}"

        pushd static/images
        for file in *.png; do
          install -Dm0644 $file $out/share/icons/hicolor/''${file//.png}/apps/${finalAttrs.pname}.png
        done
        popd
      ''
      + ''

        runHook postInstall
      '';

    postFixup = lib.optionalString (!stdenv.isDarwin) ''
      makeWrapper ${electron}/bin/electron $out/bin/${finalAttrs.pname} \
        --add-flags $out/share/lib/${finalAttrs.pname}/resources/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
        --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
        --set-default ELECTRON_IS_DEV 0 \
        --inherit-argv0
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "${finalAttrs.pname}";
        exec = "${finalAttrs.pname} %u";
        icon = "${finalAttrs.pname}";
        desktopName = "小白羊";
        startupWMClass = "小白羊";
        categories = ["AudioVideo"];
      })
    ];

    meta = with lib; {
      description = "小白羊网盘 - Powered by 阿里云盘。";
      homepage = "https://github.com/gaozhangmin/aliyunpan";
      mainProgram = "${finalAttrs.pname}";
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    };
  })
