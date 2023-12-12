{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.nvim;
in {
  options = with lib; {
    modules.nvim = {
      enable = mkEnableOption "Whether to enable nvim module";
      enGui = mkBoolOpt config.my.enGui;
      script = mkStrOpt "";
    };
  };
  # 使用lazyvim为基本配置: https://github.com/LazyVim/starter
  config = with lib;
    mkIf cfg.enable {
      environment.shellAliases = {
        vim = "nvim";
        vi = "nvim";
        v = "nvim";
      };
      # @https://discourse.nixos.org/t/stuck-writing-my-first-package/19022/4
      my = let
        sc = pkgs.lazyvim-star.out;
      in {
        user.packages = [pkgs.neovim (mkIf (cfg.enGui && pkgs.stdenvNoCC.isLinux) pkgs.neovide)];
        hm.configFile = {
          "nvim/init.lua".source = "${sc}/init.lua";
          "nvim/stylua.toml".source = "${sc}/stylua.toml";
          "nvim/lua/plugins" = {
            source = "${sc}/lua/plugins";
            recursive = true;
          };
          "nvim/lua/config/lazy.lua".source = "${sc}/lua/config/lazy.lua";
          "nvim/lua/plugins/colorscheme.lua".source = "${configDir}/nvim/colorscheme.lua";
        };
      };
      modules.nvim.script = ''
        [[ -d ${config.my.hm.dir}/.config/nvim/lua/config ]] || mkdir -p ${config.my.hm.dir}/.config/nvim/lua/config
        for i in "autocmds" "keymaps" "options" ; do
          if [[ -f ${configDir}/nvim/$i.lua ]]; then
            ln -sf ${configDir}/nvim/$i.lua ${config.my.hm.dir}/.config/nvim/lua/config/$i.lua
          elif [[ ! -f ${config.my.hm.dir}/.config/nvim/lua/config/$i.lua ]]; then
            touch ${config.my.hm.dir}/.config/nvim/lua/config/$i.lua
          fi
        done
      '';
    };
}
