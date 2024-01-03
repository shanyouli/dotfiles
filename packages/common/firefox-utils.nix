{
  runCommand,
  fetchurl,
  p7zip,
  lib,
}:
runCommand "firefox-utils" {
  pname = "firefox-utils";
  version = "2022-01-01";
  src = fetchurl {
    url = "https://github.com/xiaoxiaoflood/firefox-scripts/raw/66e896e/utils.zip";
    sha256 = "sha256-2LK3BGKSsFeMKLsXnMNz2ONJ/Wb07VTLSu4TwemYNOQ=";
  };
  nativeBuildInputs = [p7zip];
  meta = with lib; {
    homepage = "https://github.com/xiaoxiaoflood/firefox-scripts";
    description = "Firefox scripts ";
  };
} ''
  mkdir -p $out/share
  7z x $src -o$out/share
''
