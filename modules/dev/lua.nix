# modules/dev/lua.nix --- https://www.lua.org/
#
# I use lua for modding, awesomewm or Love2D for rapid gamedev prototyping (when
# godot is overkill and I have the luxury of avoiding JS). I write my Love games
# in moonscript to get around lua's idiosynchrosies. That said, I install love2d
# on a per-project basis.

{ config, options, lib, pkgs, ... }:
with lib;
{
  options.modules.dev.lua = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.dev.lua.enable {
    my = {
      packages = with pkgs; [
        lua
        luaPackages.moonscript
        luarocks
      ];
      env.LUAROCKS_HOME = "$XDG_DATA_HOME/luarocks";
      env.PATH = [ "$XDG_DATA_HOME/luarocks/bin" ];
      alias.luarocks = "luarocks --tree $LUAROCKS_HOME";
      zsh.rc = ''eval "$(luarocks path --no-bin --tree $LUAROCKS_HOME)"'';
    };
  };
}
