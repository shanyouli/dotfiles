{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.editor.nvim;
in {
  options = with lib; {
    modules.editor.nvim = {
      enable = mkEnableOption "Whether to enable nvim module";
      enGui = mkBoolOpt config.modules.opt.enGui;
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
      env.MANPAGER = "nvim +Man!";
      # @https://discourse.nixos.org/t/stuck-writing-my-first-package/19022/4
      user.packages = [pkgs.unstable.neovim (mkIf (cfg.enGui && pkgs.stdenvNoCC.isLinux) pkgs.unstable.neovide)];
      home.configFile = let
        sc = pkgs.unstable.lazyvim-star.out;
      in {
        "nvim/init.lua".source = "${sc}/init.lua";
        "nvim/stylua.toml".source = "${sc}/stylua.toml";
        "nvim/lua/plugins" = {
          source = "${sc}/lua/plugins";
          recursive = true;
        };
        "nvim/lua/config/lazy.lua".source = "${sc}/lua/config/lazy.lua";
        "nvim/lua/plugins/colorscheme.lua".source = "${config.dotfiles.configDir}/nvim/colorscheme.lua";
      };
      modules.editor.nvim.script = ''
        [[ -d ${config.user.home}/.config/nvim/lua/config ]] || mkdir -p ${config.user.home}/.config/nvim/lua/config
        for i in "autocmds" "keymaps" "options" ; do
          if [[ -f ${config.dotfiles.configDir}/nvim/$i.lua ]]; then
            ln -sf ${config.dotfiles.configDir}/nvim/$i.lua ${config.user.home}/.config/nvim/lua/config/$i.lua
          elif [[ ! -f ${config.user.home}/.config/nvim/lua/config/$i.lua ]]; then
            touch ${config.user.home}/.config/nvim/lua/config/$i.lua
          fi
        done
      '';
    };
}
