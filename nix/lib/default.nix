{ inputs, ... }:
let
  inherit (builtins) intersectAttrs functionArgs;
  # inherit (builtins) mapAttrs intersectAttrs functionArgs getEnv fromJSON;
  inherit (inputs.nixpkgs) lib;
  inherit (lib)
    attrValues
    foldr
    foldl
    makeExtensible
    ;

  # mapModules gets special treatment because it's needed early!
  inherit (attrs) mergeAttrs';
  inherit (modules) mapModules;
  attrs = import ./attrs.nix { inherit lib; };
  modules = import ./modules.nix { inherit lib attrs; };

  # 显式维护加载顺序，避免依赖 attrset 字典序。新增 lib 模块时，如果需要
  # 使用其他模块导出的参数，应放在依赖之后。
  libModules = [
    {
      name = "attrs";
      value = import ./attrs.nix;
    }
    {
      name = "modules";
      value = import ./modules.nix;
    }
    {
      name = "options";
      value = import ./options.nix;
    }
    {
      name = "utils";
      value = import ./utils.nix;
    }
    {
      name = "mkdarwin";
      value = import ./mkdarwin.nix;
    }
    {
      name = "mkhome";
      value = import ./mkhome.nix;
    }
    {
      name = "mknixos";
      value = import ./mknixos.nix;
    }
  ];

  # I embrace the callPackage pattern for lib/*.nix modules. I.e. Their
  # arguments are dynamically passed as they are loaded, drawn from a running
  # list of loaded lib/*.nix modules (plus the nixpkgs 'lib' passed to this
  # module and the whole set altogether).
  libConcat = a: b: a // { ${b.name} = b.value (intersectAttrs (functionArgs b.value) a); };
in
{
  flake = {
    lib =
      let
        libs = foldl libConcat {
          inherit lib inputs;
          self = libs;
        } libModules;
      in
      libs // (mergeAttrs' (attrValues libs));
    my =
      let
        libs = makeExtensible (
          self: with self; mapModules ./. (file: import file { inherit lib inputs attrs; })
        );
      in
      # libs = mapModules ./. (file: import file {inherit lib inputs attrs;});
      libs.extend (_self: prev: foldr (a: b: a // b) { } (attrValues prev));
  };
}
