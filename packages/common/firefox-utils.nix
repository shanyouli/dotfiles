{
  runCommand,
  p7zip,
  lib,
  source,
}:
runCommand "firefox-utils" {
  inherit (source) pname version src;
  nativeBuildInputs = [p7zip];
  meta = with lib; {
    homepage = "https://github.com/xiaoxiaoflood/firefox-scripts";
    description = "Firefox scripts ";
  };
} ''
  mkdir -p $out/share
  7z x $src -o$out/share
''
