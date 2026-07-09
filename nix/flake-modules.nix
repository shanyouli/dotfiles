{ self, ... }:
let
  inherit (self.my) relativeToRoot mapModulesRec';
  sharedMD = mapModulesRec' (relativeToRoot "modules/shared") import;
in
{
  flake = {
    nixosModules =
      let
        baseMD = [ (relativeToRoot "modules/optionals/os.nix") ];
        hardwareMD = mapModulesRec' (relativeToRoot "modules/hardware") import;
        commonMD = mapModulesRec' (relativeToRoot "modules/nixos") import;
      in
      rec {
        base =
          { ... }:
          {
            imports = baseMD;
          };
        hardware =
          { ... }:
          {
            imports = hardwareMD;
          };
        common =
          { ... }:
          {
            imports = commonMD;
          };
        owner =
          { ... }:
          {
            imports = commonMD ++ self.lib.optionals false hardwareMD;
          };
        default =
          { ... }:
          {
            imports = [
              base
              owner
            ]
            ++ sharedMD;
          };
      };
    darwinModules =
      let
        basemodule = [ (relativeToRoot "modules/optionals/os.nix") ];
        ownermodule = mapModulesRec' (relativeToRoot "modules/darwin") import;
      in
      {
        base =
          { ... }:
          {
            imports = basemodule;
          };
        owner =
          { ... }:
          {
            imports = ownermodule;
          };
        default =
          { ... }:
          {
            imports = basemodule ++ ownermodule ++ sharedMD;
          };
      };
    homeModules =
      let
        basemodule = [ (relativeToRoot "modules/optionals/hm.nix") ];
      in
      {
        base =
          { ... }:
          {
            imports = basemodule;
          };
        common =
          { ... }:
          {
            imports = sharedMD;
          };
        default =
          { ... }:
          {
            imports = basemodule ++ sharedMD;
          };
      };
  };
}
