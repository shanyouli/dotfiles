# modules/dev/lua.nix --- https://www.lua.org/
#
# I use lua for modding, awesomewm or Love2D for rapid gamedev prototyping (when
# godot is overkill and I have the luxury of avoiding JS). I write my Love games
# in moonscript to get around lua's idiosynchrosies. That said, I install love2d
# on a per-project basis.
{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  devCfg = config.modules;
  cfg = devCfg.lua;
in {
  options.modules.lua = {
    enable = mkBoolOpt false;
    xdg.enable = mkBoolOpt devCfg.enableXDG;
    extraPkgs = mkOption {
      default = self: [];
      example = literalExample "ps: [ ps.luarocks-nix ]";
      type = selectorFunction;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.lua;
      defaultText = literalExample "pkgs.lua5_4";
      example = literalExample "pkgs.lua5_4";
      description = "The Lua Package to use.";
    };
    finalPkg = mkPkgReadOpt "lua env";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      modules.lua.extraPkgs = ps: with ps; [luarocks-nix lua-cjson luacheck];
      modules.lua.package = pkgs.lua5_4;
    }
    {
      modules.lua.finalPkg = cfg.package.withPackages cfg.extraPkgs;
      my.user.packages = with pkgs; [
        cfg.finalPkg
        # lua54Packages.luarocks-nix
        stylua
        sumneko-lua-language-server
      ];
    }
  ]);
}
