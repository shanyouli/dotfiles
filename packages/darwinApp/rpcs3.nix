{ makeWrapper, fetchurl, mkDarwinApp, ... }:

mkDarwinApp rec {
  appName = "rpcs3";
  version = "0.025";
  src = fetchurl {
    url = "https://github.com/RPCS3/rpcs3-binaries-mac/releases/download/build-3f8421fc17b8508339be745eb66e585b6b17b4cf/rpcs3-v0.0.25-14374-3f8421fc_macos.dmg";
    sha256 = "4C760C0D09C1CE8730040038EA8023972DFF05E4D29BACCD609C95F900EC085A";
  };
  appMeta =  {
    description = "IINA mplayer";
    homepage = "http://iina.io/";
  };
  # postInstall = ''
  #   makeWrapper $out/Applications/IINA.app/Contents/MacOS/iina-cli $out/bin/iina
  # '';
}
