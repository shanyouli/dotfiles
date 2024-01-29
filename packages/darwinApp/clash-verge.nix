{
  mkDarwinApp,
  source,
  lib,
  ...
}:
mkDarwinApp rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  meta = {
    description = "A Clash GUI based on tauri. Supports Windows, macOS and Linux. ";
    homepage = "https://github.com/zzzgydi/clash-verge";
  };
}
