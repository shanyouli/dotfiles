{self, ...}: {
  perSystem = {
    system,
    lib,
    pkgs,
    ...
  }: let
    my = lib.makeExtensible (_: self.my.mapModules ./. (f: import f {inherit lib system self pkgs;}));
    mylib = self.my // (my.extend (_final: prev: lib.foldr (a: b: a // b) {} (lib.attrValues prev)));
  in {
    _module.args.my = mylib;
    # _module.args.myvars = import ./dirs.nix {inherit lib system self pkgs;};
  };
}
