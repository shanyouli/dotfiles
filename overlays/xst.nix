let version = "0.8.4.1";
in
# see @https://nixos.wiki/wiki/Overlays#Overriding_a_version
final: prev: {
  xst = prev.xst.overrideAttrs (old: {
    name = "xst-${version}";
    src = prev.fetchFromGitHub {
      owner = "gnotclub";
      repo = "xst";
      rev = "v${version}";
      sha256 = "sha256-nOJcOghtzFkl7B/4XeXptn2TdrGQ4QTKBo+t+9npxOA=";
      # sha256 = "sha256-nOJcOghtzFkl7B/4XeXptn2TdrGQ4QTKBo+t+9npxOA=";
    };
  });
}
