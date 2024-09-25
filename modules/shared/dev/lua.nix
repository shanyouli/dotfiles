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
  my,
  ...
}:
with lib;
with my; let
  devCfg = config.modules.dev;
  cfg = devCfg.lua;
in {
  options.modules.dev.lua = {
    enable = mkBoolOpt false;
    extraPkgs = mkOption {
      default = _self: [];
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
  config = mkIf cfg.enable {
    modules = {
      app.editor.nvim.lsp = ["lua_ls"];
      dev.lua = {
        extraPkgs = ps: with ps; [luarocks-nix lua-cjson luacheck];
        package = pkgs.lua5_4;
        finalPkg = cfg.package.withPackages cfg.extraPkgs;
      };
    };
    home.packages = with pkgs; [
      cfg.finalPkg
      # lua54Packages.luarocks-nix
      stylua # fmt
      sumneko-lua-language-server # lsp
    ];
  };
}
