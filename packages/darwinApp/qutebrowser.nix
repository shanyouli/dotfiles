{
  mkDarwinApp,
  source,
  lib,
  ...
}:
mkDarwinApp rec {
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  inherit (source) pname src;
  meta = {
    description = "Keyboard-driven, vim-like browser based on PyQt5";
    homepage = "https://www.qutebrowser.org/";
  };
}
