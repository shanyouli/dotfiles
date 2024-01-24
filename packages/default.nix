let
  pythonDir = ./python;
  hasNixSuffix = str: let
    sLen = builtins.stringLength str;
  in (sLen > 4 && builtins.substring (sLen - 4) sLen str == ".nix");
  removeNixSuffix = str: let
    sLen = builtins.stringLength str;
  in
    if (sLen > 4 && builtins.substring (sLen - 4) sLen str == ".nix")
    then builtins.substring 0 (sLen - 4) str
    else str;
  mapPackages = {
    namefn ? removeNixSuffix,
    fn,
    dir,
  }:
    with builtins;
      listToAttrs (map (n: {
          name = namefn n;
          value = fn n;
        }) (filter (v:
          v
          != null) (attrValues (mapAttrs (
          k: v:
            if
              (
                (v == "directory" && k != "_sources" && pathExists "${toString ./.}/${k}/default.nix")
                || (v == "regular" && hasNixSuffix k && k != "default.nix")
              )
            then k
            else null
        ) (readDir dir)))));
  mapPkgs = dir: fn: mapPackages {inherit dir fn;};
in rec {
  packages = pkgs: mapPkgs (name: pkgs.${name});
  overlay = final: prev: let
    sources = (import ./_sources/generated.nix) {inherit (final) fetchgit fetchurl fetchFromGitHub dockerTools;};
    packageOverrides = pfinal: pprev:
      mapPkgs pythonDir (
        name: let
          package = import "${builtins.toString pythonDir}/${name}";
          args = builtins.intersectAttrs (builtins.functionArgs package) {
            source = sources.${removeNixSuffix name};
            python3Packages = pfinal;
          };
        in
          pfinal.toPythonModule (final.callPackage package args)
      );
  in
    rec {
      python3 = prev.python3.override {inherit packageOverrides;};
      python3Packages = python3.pkgs;

      pypy3 = prev.python3.override {inherit packageOverrides;};
      pypy3Packages = pypy3.pkgs;

      python39 = prev.python39.override {inherit packageOverrides;};
      python39Packages = python39.pkgs;

      python310 = prev.python310.override {inherit packageOverrides;};
      python310Packages = python310.pkgs;
    }
    // {};
}
