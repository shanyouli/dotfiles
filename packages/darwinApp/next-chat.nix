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
  appname = "NextChat";
  meta = {
    description = "ChatGpt Next Web";
    homepage = "https://github.com/Yidadaa/ChatGPT-Next-Web";
  };
}
