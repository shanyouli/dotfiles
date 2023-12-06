{
  fetchurl,
  mkDarwinApp,
  makeWrapper,
  ...
}:
mkDarwinApp rec {
  appName = "uPic";
  version = "0.21.1";
  useDmg = false;
  useZip = true;
  extBuildInputs = [makeWrapper];
  postInstall = ''
    makeWrapper $out/Applications/uPic.app/Contents/MacOS/uPic $out/bin/upic
  '';
  src = fetchurl {
    url = "https://github.com/gee1k/uPic/releases/download/v${version}/uPic.zip";
    sha256 = "1152e2f3995cc33d16d764348618a70a9fb067f2b17f548a813646809aa1154c";
  };

  meta = {
    description = "upic 图床管理";
    homepage = "https://github.com/gee1k/uPic";
  };
}
