{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "lazyvim-star";
  version = "2023-08";
  src = fetchFromGitHub {
    owner = "LazyVim";
    repo = "starter";
    rev = "92b2689e6f11004e65376e84912e61b9e6c58827";
    sha256 = "sha256-gE2tRpglA0SxxjGN+uKwkwdR5YurvjVGf8SRKkW0E1U=";
  };

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
