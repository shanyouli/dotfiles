let
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
    dir,
    fn,
    namefn,
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
                (v == "directory" && k != "_sources" && pathExists "${toString dir}/${k}/default.nix")
                || (v == "regular" && hasNixSuffix k && k != "default.nix")
              )
            then k
            else null
        ) (readDir dir)))));

  mapPythonPkgs = callFn: sources: python3Packages: let
    dir = ./python;
    namefn = removeNixSuffix;
    fn = name: let
      package = import ./python/${name};
      args = builtins.intersectAttrs (builtins.functionArgs package) {
        inherit python3Packages;
        source = sources.${namefn name};
      };
    in
      callFn package args;
  in
    mapPackages {inherit dir fn namefn;};

  mapPkgs = dir: callFn: sources: let
    namefn = removeNixSuffix;
    fn = name: let
      package = import "${builtins.toString dir}/${name}";
      args = builtins.intersectAttrs (builtins.functionArgs package) {
        inherit sources;
        source = sources.${namefn name};
      };
    in
      callFn package args;
  in
    mapPackages {inherit dir fn namefn;};
in rec {
  # packages = pkgs: mapPkgs (name: pkgs.${name});
  overlay = final: prev: let
    sources = (import ../_sources/generated.nix) {inherit (final) fetchurl fetchFromGitHub fetchgit dockerTools;};
    callPkg = package: args: final.callPackage package args;
    packageOverrides = pfinal: pprev:
      {
        httpx = pprev.httpx.overrideAttrs (old: {
          inherit (sources.httpx) pname version src;
        });
      }
      // mapPythonPkgs (package: args: (pfinal.toPythonModule (callPkg package args))) sources pfinal;
  in
    rec
    {
      python3 = prev.python3.override {inherit packageOverrides;};
      python3Packages = python3.pkgs;

      pypy3 = prev.python3.override {inherit packageOverrides;};
      pypy3Packages = pypy3.pkgs;

      python39 = prev.python39.override {inherit packageOverrides;};
      python39Packages = python39.pkgs;

      python310 = prev.python310.override {inherit packageOverrides;};
      python310Packages = python310.pkgs;
    }
    // (mapPkgs ./common callPkg sources)
    // (mapPkgs ./darwin callPkg sources);
}
