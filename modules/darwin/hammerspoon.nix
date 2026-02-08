{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.hammerspoon;
  cfmLua = config.modules.dev.lua;
  useDevLua = cfmLua.enable && ((versions.majorMinor cfmLua.package.version) == "5.4");
  luaEnv = if useDevLua then cfmLua.finalPkg else pkgs.lua5_4.withPackages cfg.luaExtensions;
in
{
  options.modules.macos.hammerspoon = {
    enable = mkBoolOpt false;
    luaExtensions = mkOption {
      default = _self: [ ];
      example = literalExpression "ps: [ps.lyaml]";
      type = selectorFunction;
    };
    cmd = mkOption {
      default = { };
      type = types.attrsOf types.str;
      example = literalExpression ''
        {
          emacscmd = "/bin/emacs";
        }
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      homebrew.casks = [ "hammerspoon" ];
      homebrew.brews = [ "blueutil" ];
      # 使用 hammerspoon 来管理 如何打开 url
      # user.packages = [pkgs.defaultbrowser];
      home.configFile."hammerspoon/nixpath.lua".text =
        let
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
        in
        ''
          ${luaPaths}
          ${optionalString useDevLua ''
            package.path = package.path .. ";${config.home.dataDir}/luarocks/share/lua/5.4/?.lua;${config.home.dataDir}/share/lua/5.4/?/init.lua"
            package.cpath = package.cpath .. ";${config.home.dataDir}/luarocks/lib/lua/5.4/?.so;${config.home.dataDir}/luarocks/lib/lua/5.4/?.dylib"
          ''}
          local fennel = require("fennel")
          table.insert(package.loaders or package.searchers, fennel.searcher)
          return {
            ${concatStringsSep ",\n" (
              mapAttrsToList (n: v: ''${n} = "${v}"'') (filterAttrs (_n: v: v != "") cfg.cmd)
            )}
          }
        '';
      my.user.init.InitHammerspoon = {
        desc = "change hammerspoon config Dir";
        text = ''
          defaults write org.hammerspoon.Hammerspoon MJConfigFile "${config.home.configDir}/hammerspoon/init.lua"
        '';
      };
      modules.macos.hammerspoon.luaExtensions =
        ps: with ps; [
          fennel
          jeejah
        ];
    }
    (mkIf useDevLua { modules.dev.lua.extraPkgs = cfg.luaExtensions; })
  ]);
}
