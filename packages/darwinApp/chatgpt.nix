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
  appname = "ChatGPT";
  meta = {
    description = "ChatGPT Desktop Application (Mac, Windows and Linux) ";
    homepage = "https://app.nofwl.com/chatgpt";
  };
}
