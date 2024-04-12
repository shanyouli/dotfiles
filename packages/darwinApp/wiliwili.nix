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
  meta = {
    description = "第三方B站客户端";
    # homepage = "http://zyplayer.fun/";
    homepage = "https://github.com/xfangfang/wiliwili";
  };
}
