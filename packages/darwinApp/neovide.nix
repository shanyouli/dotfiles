{
  mkDarwinApp,
  makeWrapper,
  source,
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  nativeBuildInputs = [makeWrapper];
  postInstall = ''
    makeWrapper $out/Applications/neovide.app/Contents/MacOS/neovide $out/bin/neovide
  '';
  meta = {
    description = "No Nonsense Neovim Client in Rust";
    homepage = "https://neovide.dev/";
  };
}
