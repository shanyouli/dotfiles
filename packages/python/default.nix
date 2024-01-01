final: prev: let
  pkgs = prev;
  lib = pkgs.lib;
  mapCurrentDir = {
    namefn ? (n: lib.removeSuffix ".nix" n),
    fn,
  }:
    lib.mapAttrs' (name: type: {
      name = namefn name;
      value = let
        file = ./. + "/${name}";
      in
        fn file;
    }) (lib.filterAttrs (name: type:
      (type
        == "directory"
        && builtins.pathExists "${toString ./.}/${name}/default.nix")
      || (type
        == "regular"
        && lib.hasSuffix ".nix" name
        && !(name == "default.nix")))
    (builtins.readDir ./.));
  packageOverrides = pfinal: pprev:
    mapCurrentDir {fn = f: pfinal.toPythonModule (final.callPackage f {python3Packages = pfinal;});};
in rec {
  python3 = pkgs.python3.override {inherit packageOverrides;};
  python3Packages = python3.pkgs;

  pypy3 = pkgs.python3.override {inherit packageOverrides;};
  pypy3Packages = pypy3.pkgs;

  python39 = pkgs.python39.override {inherit packageOverrides;};
  python39Packages = python39.pkgs;

  python310 = pkgs.python310.override {inherit packageOverrides;};
  python310Packages = python310.pkgs;
}
