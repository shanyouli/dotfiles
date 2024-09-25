{
  inputs,
  self,
  ...
}: {
  perSystem = {system, ...}: {
    _module.args.pkgs = let
      inherit (inputs) darwin-stable nixos-stable;
      inherit (self) my;
      mypkgs =
        if my.isDarwin system
        then darwin-stable
        else nixos-stable;
    in
      import mypkgs {
        inherit system;
        overlays = [self.overlay];
        config.allowUnfree = true;
      };
  };
}
