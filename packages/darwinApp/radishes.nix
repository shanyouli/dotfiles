{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "radishes";
  version = "2.0.0-alpha.5";
  useSystemCmd = true;
  useDmg = false;
  src = fetchurl {
    url = "https://github.com/radishes-music/radishes/releases/download/v${version}/radishes.Setup.${version}.dmg";
    sha256 = "1q6bwv9s0b63vayra014r31lkksnqmcbcvdi611fj6vc5g6369yz";
  };
  pathdir = "${appName} ${version}";
  appMeta = {
    description = "Cross-platform copyright-free music platform";
    homepage = "https://github.com/radishes-music/radishes";
  };
}
