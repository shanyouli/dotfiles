{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.macos.hammerspoon;
  cfmLua = config.my.modules.lua;
in {
  options.my.modules.macos.hammerspoon = {enable = mkBoolOpt false;};

  config = mkIf cfg.enable {
    homebrew.casks = ["hammerspoon"];
    homebrew.brews = ["blueutil"];
    my.user.packages = [pkgs.defaultbrowser];
    my.hm.configFile."hammerspoon/nixpath.lua".text = let
      luaPaths = lib.optionalString (cfmLua.enable
        && ((pkgs.lib.take 2 (builtins.splitVersion cfmLua.package.version))
          == ["5" "4"])) ''
        -- 使用nix中安装的lua环境
        local paths = {
          package.path ,
          "${config.my.modules.lua.finalPkg}" .. "/share/lua/5.4/?.lua",
          "${config.my.modules.lua.finalPkg}" .. "/share/lua/5.4/?/init.lua"
                      }
        local cpaths = {
          package.cpath ,
          "${config.my.modules.lua.finalPkg}" .. "/lib/lua/5.4/?.dylib",
          "${config.my.modules.lua.finalPkg}" .. "/lib/lua/5.4/?.so"
                      }
        package.path = table.concat(paths, ";")
        package.cpath = table.concat(cpaths, ";")
      '';
      yabaiCmd = lib.optionalString config.my.modules.macos.yabai.enable ''
        yabaicmd="${config.services.yabai.package}/bin/yabai",
      '';
      emacsClient = lib.optionalString config.my.modules.macos.emacs.enable ''
        emacsClient = "${config.my.modules.emacs.pkg}/bin/emacsclient",
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
      enable = true;
      text = ''
        /usr/bin/defaults write org.hammerspoon.Hammerspoon MJConfigFile \
          "${config.my.hm.configHome}/hammerspoon/init.lua"
      '';
      desc = "Init Hammerspoon File";
    };
  };
}
