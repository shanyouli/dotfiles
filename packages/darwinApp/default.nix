{...}: final: prev:
# with lib;
let
  pkgs = prev;
  lib = pkgs.lib;
  # https://discourse.nixos.org/t/help-with-error-only-hfs-file-systems-are-supported-on-ventura/25873
  # https://stackoverflow.com/questions/11679475/extract-from-dmg/28641849#28641849
  mkDarwinApp = {
    appName, # app name
    version, # 当前使用的版本
    src, # 源代码地址
    extBuildInputs ? [], # 额外需要增加的构建工具
    appMeta ? {}, # appMeta 其他信息
    postInstall ? "", # 安装后的其他配置脚本
    useZip ? false, # 使用zip解压
    useDmg ? true, # 使用dmg解压
    useSystemCmd ? false, # 使用系统挂载方法
    pathdir ? "",
    ...
  }:
    assert pkgs.stdenv.isDarwin;
      pkgs.stdenv.mkDerivation rec {
        inherit version src postInstall;
        nativeBuildInputs =
          extBuildInputs
          ++ lib.optionals useDmg [pkgs.undmg]
          ++ lib.optionals useZip [pkgs.unzip];
        name = "${
          builtins.replaceStrings [" "] ["_"] (lib.toLower appName)
        }-darwin-${version}";
        sourceRoot = ".";
        unpackPhase = ''
          runHook preUnpack
          ${lib.optionalString useZip ''unzip $src''}
          _pathDmg="${pathdir}.dmg"
          [[ ''${src: -4} == ".dmg" ]] && _pathDmg=$src
          echo $_pathDmg
          ${lib.optionalString useDmg ''undmg $_pathDmg''}
          ${lib.optionalString useSystemCmd ''/usr/bin/hdiutil attach $_pathDmg''}
          runHook postUnpack
        '';

        installPhase = ''
          mkdir -p "$out/Applications"
          ${
            if (pathdir == "")
            then ''
              mv -f *.app "$out/Applications"
            ''
            else ''
              cp -r "/Volumes/${pathdir}"/*.app "$out/Applications"
            ''
          }
          ${lib.optionalString (postInstall != "") ''
            runHook postInstall
          ''}
        '';
        meta = with lib; appMeta // {platforms = platforms.darwin;};
      };
in
  lib.mapAttrs' (name: type: {
    name = (lib.removeSuffix ".nix" name) + "-app";
    value = let
      file = ./. + "/${name}";
    in
      lib.callPackageWith
      (pkgs // {inherit mkDarwinApp;})
      file {};
  }) (lib.filterAttrs (name: type:
    (type
      == "directory"
      && builtins.pathExists "${toString ./.}/${name}/default.nix")
    || (type
      == "regular"
      && lib.hasSuffix ".nix" name
      && !(name == "default.nix")))
  (builtins.readDir ./.))
