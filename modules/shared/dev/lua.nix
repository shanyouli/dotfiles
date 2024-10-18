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
  cfg_version = versions.majorMinor cfg.package.version;
in {
  options.modules.dev.lua = {
    enable = mkBoolOpt false;
    fennel.enable = mkBoolOpt cfg.enable;

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
        extraPkgs = ps: with ps; [luarocks-nix (mkIf cfg.fennel.enable fennel)];
        package = pkgs.lua5_4;
        finalPkg = cfg.package.withPackages cfg.extraPkgs;
      };
      shell = {
        env.LUAROCKS_HOME = "$XDG_DATA_HOME/luarocks";
        zsh.rcInit = ''alias luarocks="luarocks --tree=$LUAROCKS_HOME"'';
        bash.rcInit = ''alias luarocks="luarocks --tree=$LUAROCKS_HOME"'';
        nushell.rcInit = ''
          def --wrapped luarocks [...rest ] {
            if ($rest | any { |x| $x | str starts-with "--tree=" }) {
              ^luarocks ...$rest
            } else {
              ^luarocks $"--tree=($env.LUAROCKS_HOME)" ...$rest
            }
          }
        '';
        fish.rcInit = ''alias luarocks="luarocks --tree=$LUAROCKS_HOME"'';
      };
    };
    home = {
      packages = with pkgs; [
        cfg.finalPkg
        stylua # fmt
        sumneko-lua-language-server # lsp
        selene # a fast modern lua linter. 比 luacheck 更好
      ];
      initExtra = ''
        print $"Init (ansi green_bold)Luarocks(ansi reset) ..."
        let lua_configDir = $env.HOME + "/.config/luarocks"
        let lua_configFile = $lua_configDir + "/config_${cfg_version}.lua"
        ^mkdir -p $lua_configDir
        if (not ($lua_configFile | path expand | path exists)) {
          touch $lua_configFile
        }
      '';
    };
  };
}
