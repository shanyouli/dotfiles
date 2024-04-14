{
  mkDarwinApp,
  source,
  lib,
}:
mkDarwinApp rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  appname = "Alexandria";
  meta = {
    description = "A minimalistic cross-platform eBook reader built with Tauri, Epub.js, and Typescript";
    homepage = "https://github.com/btpf/Alexandria";
  };
}
