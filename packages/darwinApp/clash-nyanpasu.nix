{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "clash-nyanpasu";
  version = "1.4.1";
  useSystemCmd = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/keiko233/clash-nyanpasu/releases/download/v${version}/Clash.Nyanpasu_${version}_aarch64.dmg";
    sha256 = "14h0y24rfqac3pl8nm98s0rin0ajsqwd4ydiqb4lzih73dhwc5ap";
  };
  pathdir = "Clash Nyanpasu";
  appMeta = {
    description = "Clash Nyanpasu! (∠・ω< )⌒☆​";
    # homepage = "http://zyplayer.fun/";
    homepage = "https://github.com/keiko233/clash-nyanpasu";
  };
}
