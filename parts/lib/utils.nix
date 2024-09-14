{lib, ...}: rec {
  isDarwin = system: builtins.elem system lib.platforms.darwin;

  relativeToRoot = lib.path.append ../../.;
}
