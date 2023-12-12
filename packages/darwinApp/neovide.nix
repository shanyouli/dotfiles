{
  fetchurl,
  mkDarwinApp,
  makeWrapper,
  ...
}:
mkDarwinApp rec {
  appName = "neovide";
  version = "0.11.2";
  pathdir = "neovide";
  useSystemCmd = true;
  useDmg = false;
  useZip = true;
  src = fetchurl {
    url = "https://github.com/neovide/neovide/releases/download/${version}/neovide.dmg.zip";
    sha256 = "1279jvr3pzjxyd0323lzn4jmf6z9hcw0narh3fgxc0ja14lwi9i3";
  };
  extBuildInputs = [makeWrapper];
  postInstall = ''
    makeWrapper $out/Applications/neovide.app/Contents/MacOS/neovide $out/bin/neovide
  '';
  meta = {
    description = "No Nonsense Neovim Client in Rust";
    homepage = "https://neovide.dev/";
  };
}
