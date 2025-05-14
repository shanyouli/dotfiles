{ self, ... }:
let
  inherit (self.my) relativeToRoot mapModulesRec';
in
{
  flake.homeModules =
    let
      basemodule = [ (relativeToRoot "modules/optionals/hm.nix") ];
      commonModule = mapModulesRec' (relativeToRoot "modules/shared") import;
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
          imports = commonModule;
        };
      default =
        { ... }:
        {
          imports = basemodule ++ commonModule;
        };
    };
}
