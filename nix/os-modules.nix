{ self, ... }:
let
  inherit (self.my) relativeToRoot mapModulesRec';
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
        # owner = hardware ++ common; # 暂时没有使用 hardware 模块
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
              self.homeModules.common
            ];
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
            imports = basemodule ++ ownermodule;
          };
      };
  };
}
