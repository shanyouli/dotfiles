let version = "0.8.4.201119";
in
# see @https://nixos.wiki/wiki/Overlays#Overriding_a_version
final: prev: {
  xst = prev.xst.overrideAttrs (old: {
    name = "xst-${version}";
    src = prev.fetchFromGitHub {
      owner = "gnotclub";
      repo = "xst";
      rev = "9837593355c15c8bdf607edefda9f72d32098ae3";
      sha256 = "sha256-nOJcOghtzFkl7B/4XeXptn2TdrGQ4QTKBo+t+9npxOA=";
    };
  });
}
