{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) removeAttrs optionals optionalString;
in rec {
  # package -> pkg
  # dir -> path
  # args_ -> attrs
  mkHomePkg' = package: dir: args_: let
    name = "${package.pname}-wrapper-${package.version}";
    _nativeBuildInputs = [pkgs.makeWrapper] ++ optionals (args_ ? nativeBuildInputs) args_.nativeBuildInputs;
    paths = [package] ++ optionals (args_ ? paths) args_.paths;
    postBuild = ''
      if [[ -d $out/bin ]]; then
        for i in $out/bin/* ; do
          wrapProgram $out/bin/$(basename ''${i}) --set HOME "${dir}"
        done
      fi
      ${optionalString (args_ ? postBuild) args_.postBuild}
    '';
    arg_ =
      (removeAttrs args_ ["nativeBuildInputs" "paths" "postBuild"])
      // {
        inherit name paths postBuild;
        nativeBuildInputs = _nativeBuildInputs;
      };
    # args = {};
  in
    pkgs.symlinkJoin arg_;
  mkHomePkg = package: dir: mkHomePkg' package dir {};

  # toJsonFile :: (attrs -> jsonFile)
  toJsonFile = attrs: (pkgs.formats.json {}).generate "prettyJSON" attrs;

  # toTomlFile :: (attrs -> tomlFile)
  toTomlFile = attrs: (pkgs.formats.toml {}).generate "prettyTOML" attrs;
}
