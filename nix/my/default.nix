{ self, ... }:
{
  perSystem =
    {
      system,
      lib,
      pkgs,
      ...
    }:
    let
      myModules = lib.makeExtensible (
        _:
        self.my.mapModules ./. (
          f:
          import f {
            inherit
              lib
              system
              self
              pkgs
              ;
          }
        )
      );
      myFlat = myModules.extend (_final: prev: lib.foldr (a: b: a // b) { } (lib.attrValues prev));
      mylib =
        self.my
        // myFlat
        // {
          vars = myFlat.vars or { };
          paths = myFlat.paths or { };
          pkg = myFlat.pkg or { };
          nu = myFlat.nu or { };
        };
    in
    {
      _module.args.my = mylib;
      # _module.args.myvars = import ./dirs.nix {inherit lib system self pkgs;};
    };
}
