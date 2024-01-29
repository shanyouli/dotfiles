{
  lib,
  stdenv,
  source,
}:
stdenv.mkDerivation rec {
  inherit (source) pname src;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  # https://github.com/tdlib/td/issues/1974
  postPatch = ''
    substituteInPlace ./lua/config/lazy.lua \
      --replace 'checker = { enabled = true },' 'checker = { enabled = false },'
  '';
  installPhase = ''
    mkdir -p $out
    mv -f * $out/
  '';
  meta = with lib; {
    description = "LazyVim is a Neovim setup powered by 💤 lazy.nvim to make it easy to customize and extend your config.";
    homepage = "https://www.lazyvim.org/";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
