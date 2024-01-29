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

  appname = "Clash Nyanpasu";
  meta = {
    description = "Clash Nyanpasu! (∠・ω< )⌒☆​";
    homepage = "https://github.com/keiko233/clash-nyanpasu";
  };
}
