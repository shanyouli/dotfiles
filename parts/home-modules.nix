{self, ...}: let
  inherit (self.lib.my) relativeToRoot mapModulesRec';
in {
  flake.homeModules = rec {
    base = [(relativeToRoot "modules/optionals/hm.nix")];
    common = (mapModulesRec' (relativeToRoot "modules/shared") import);
    default = base ++ common;
  };
}
