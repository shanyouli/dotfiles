{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfg = config.modules.macos.hammerspoon;
  cfmLua = config.modules.dev.lua;
  useDevLua = cfmLua.enable && ((versions.majorMinor cfmLua.package.version) == "5.4");
  luaEnv =
    if useDevLua
    then cfmLua.finalPkg
    else pkgs.lua5_4.withPackages cfg.luaExtensions;
in {
  options.modules.macos.hammerspoon = {
    enable = mkBoolOpt false;

    luaExtensions = mkOption {
      default = _self: [];
      example = literalExample "ps: [ps.lyaml]";
      type = selectorFunction;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      homebrew.casks = ["hammerspoon"];
      homebrew.brews = ["blueutil"];
      # 使用 hammerspoon 来管理 如何打开 url
      # user.packages = [pkgs.defaultbrowser];
      home.configFile."hammerspoon/nixpath.lua".text = let
        luaPaths = ''
          -- 使用nix中安装的lua环境
          local paths = {
            package.path,
            "${luaEnv}" .. "/share/lua/5.4/?.lua",
            "${luaEnv}" .. "/share/lua/5.4/?/init.lua",
          }
          local cpaths = {
            package.cpath,
            "${luaEnv}" .. "/lib/lua/5.4/?.dylib",
            "${luaEnv}" .. "/lib/lua/5.4/?.so",
          }
          package.path = table.concat(paths, ";")
          package.cpath = table.concat(cpaths, ";")
        '';
        yabaiCmd = lib.optionalString config.modules.service.yabai.enable ''
          yabaicmd="${config.modules.service.yabai.package}/bin/yabai",
        '';
        emacsClient = lib.optionalString config.modules.app.editor.emacs.enable ''
          emacsClient = "${config.modules.app.editor.emacs.pkg}/bin/emacsclient",
        '';
      in ''
        ${luaPaths}
        ${optionalString useDevLua ''
          package.path = package.path .. ";${config.home.dataDir}/luarocks/share/lua/5.4/?.lua;${config.home.dataDir}/share/lua/5.4/?/init.lua"
          package.cpath = package.cpath .. ";${config.home.dataDir}/luarocks/lib/lua/5.4/?.so;${config.home.dataDir}/luarocks/lib/lua/5.4/?.dylib"
        ''}
        local fennel = require("fennel")
        table.insert(package.loaders or package.searchers, fennel.searcher)
        return {
          ${yabaiCmd}
          ${emacsClient}
        }
      '';
      macos.userScript.setHMInitFile = {
        text = ''
          defaults write org.hammerspoon.Hammerspoon MJConfigFile \
            "${config.home.configDir}/hammerspoon/init.lua"
        '';
        desc = "Init Hammerspoon File";
      };
      modules.macos.hammerspoon.luaExtensions = ps: with ps; [fennel];
    }
    (mkIf useDevLua {
      modules.dev.lua.extraPkgs = cfg.luaExtensions;
    })
  ]);
}
