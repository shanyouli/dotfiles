{
  mkDarwinApp,
  source,
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  appname = "Clash Nyanpasu";
  meta = {
    description = "Clash Nyanpasu! (∠・ω< )⌒☆​";
    # homepage = "http://zyplayer.fun/";
    homepage = "https://github.com/keiko233/clash-nyanpasu";
  };
}
