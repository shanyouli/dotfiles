{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.macos.hammerspoon;
  cfmLua = config.modules.dev.lua;
in {
  options.modules.macos.hammerspoon = {enable = mkBoolOpt false;};

  config = mkIf cfg.enable {
    homebrew.casks = ["hammerspoon"];
    homebrew.brews = ["blueutil"];
    user.packages = [pkgs.defaultbrowser];
    home.configFile."hammerspoon/nixpath.lua".text = let
      luaPaths = lib.optionalString (cfmLua.enable
        && ((pkgs.lib.take 2 (builtins.splitVersion cfmLua.package.version))
          == ["5" "4"])) ''
        -- 使用nix中安装的lua环境
        local paths = {
          package.path ,
          "${config.modules.dev.lua.finalPkg}" .. "/share/lua/5.4/?.lua",
          "${config.modules.dev.lua.finalPkg}" .. "/share/lua/5.4/?/init.lua"
        }
        local cpaths = {
          package.cpath ,
          "${config.modules.dev.lua.finalPkg}" .. "/lib/lua/5.4/?.dylib",
          "${config.modules.dev.lua.finalPkg}" .. "/lib/lua/5.4/?.so"
        }
        package.path = table.concat(paths, ";")
        package.cpath = table.concat(cpaths, ";")
      '';
      yabaiCmd = lib.optionalString config.modules.service.yabai.enable ''
        yabaicmd="${config.modules.service.yabai.package}/bin/yabai",
      '';
      emacsClient = lib.optionalString config.modules.macos.emacs.enable ''
        emacsClient = "${config.modules.editor.emacs.pkg}/bin/emacsclient",
      '';
      defaultBrowser = ''
        defaultbrowser = "${pkgs.defaultbrowser}/bin/defaultbrowser",
      '';
    in ''
      ${luaPaths}

      return {
        ${yabaiCmd}
        ${emacsClient}
        ${defaultBrowser}
      }
    '';
    macos.userScript.setHMInitFile = {
      text = ''
        defaults write org.hammerspoon.Hammerspoon MJConfigFile \
          "${config.home.configDir}/hammerspoon/init.lua"
      '';
      desc = "Init Hammerspoon File";
    };
  };
}
