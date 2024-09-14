{
  inputs,
  self,
  ...
}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: let
    oscheck = let
      osConfig =
        if pkgs.stdenvNoCC.isDarwin
        then self.darwinConfigurations
        else self.nixosConfigurations;
    in
      osConfig."test@${system}".config.system.build.toplevel;
    homecheck = self.legacyPackages.${system}.homeConfigurations.test.activationPackage;
  in {
    checks.os = oscheck;
    checks.home = homecheck;
    checks.default =
      if (inputs ? treefmt-nix)
      then self.checks.${system}.treefmt
      else homecheck;
  };
}
