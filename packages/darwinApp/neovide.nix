{
  mkDarwinApp,
  makeWrapper,
  source,
  lib,
}:
mkDarwinApp rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  nativeBuildInputs = [makeWrapper];
  postInstall = ''
    makeWrapper $out/Applications/neovide.app/Contents/MacOS/neovide $out/bin/neovide
  '';
  meta = {
    description = "No Nonsense Neovim Client in Rust";
    homepage = "https://neovide.dev/";
  };
}
