{
  mkDarwinApp,
  makeWrapper,
  source,
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  appname = "uPic";
  nativeBuildInputs = [makeWrapper];
  postInstall = ''
    makeWrapper $out/Applications/uPic.app/Contents/MacOS/uPic $out/bin/upic
  '';
  meta = {
    description = "upic 图床管理";
    homepage = "https://github.com/gee1k/uPic";
  };
}
