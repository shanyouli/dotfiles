{pkgs}: let
  # 文件来源 @see https://github.com/ldeck/nix-home/raw/09bf1a8a00608084b8bc075086111c5a7e89151d/lib/defaults/apps/macOS/lib/app.nix
  inherit (pkgs) unzip undmg stdenv lib p7zip;
in
  {
    pname,
    appname ? pname,
    version,
    src,
    meta ? {},
    postInstall ? "",
    nativeBuildInputs ? [],
    sourceRoot ? ".",
    ...
  }:
    assert stdenv.isDarwin;
      stdenv.mkDerivation {
        inherit version src postInstall sourceRoot nativeBuildInputs pname;
        buildInputs = [unzip undmg p7zip];
        name = "${
          builtins.replaceStrings [" "] ["_"] (lib.toLower pname)
        }-darwin-${version}";

        unpackCmd = ''
          _pathDmg=""
          _app=""
          function lower() { printf '%s\n' "''${1,,}"; }
          echo "File to unpack: $curSrc"
          if [[ "$curSrc" =~ \.dmg$ ]]; then
            _pathDmg=$src
          fi
          if [[ "$_pathDmg" == "" ]]; then
            case "$(lower "$curSrc")" in
              *.zip) unzip $src;;
              *.7z) 7z x $src;;
              *.tar.gz|*.tgz) tar -zxvf $src ;;
            esac
            _pathDmg=$(find . -maxdepth 2 -name "*.dmg" | head -n 1)
            _app=$(find . -maxdepth 2 -name "*.app" | head -n 1)
          fi

          if [[ "" == $_app ]]; then
            echo $_pathDmg will undmg
            if undmg $_pathDmg >/dev/null 2>&1; then
              _app=$(find . -maxdepth 1 -name "*.app" | head -n 1)
            else
              _mnt=$(mktemp -d -t ci-XXXXXXXXXX)
              echo "Attahing $_mnt"
              /usr/bin/hdiutil attach -nobrowse -readonly $_pathDmg -mountpoint $_mnt
              echo "What's in the mount dir"?
              ls -la $_mnt/
              _app=$(find $_mnt/ -maxdepth 1 -name "*.app")
            fi
          fi
          echo "Copying contents"
          if [[ $(dirname "$_app") != "." ]] && [[ $(dirname "$_app") != $PWD ]]; then
            cp -a "$_app" "$PWD/"
          fi
          ls -al $PWD
          if [[ -n $_mnt ]]; then
            echo "Detaching $_mnt"
            /usr/bin/hdiutil detach -force $_mnt
            rm  -rf $_mnt
          fi
          echo "clear pack...."
          find . -maxdepth 1 ! -iname "*.app"  -exec rm -rf {} \;
        '';
        phases = ["unpackPhase" "installPhase"];
        installPhase =
          ''
            mkdir -p "$out/Applications/${appname}.app"
            cp -a *.app/. "$out/Applications/${appname}.app"
          ''
          + postInstall;
        meta = {platforms = lib.platforms.darwin;} // meta;
      }
