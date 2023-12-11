{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.dev;
  modules = config.modules;
in {
  options = {
    modules.dev = {
      enable = mkEnableOption "Whether to enable dev module ";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      my.user.packages = with pkgs; [
        #  bash lanaguage, lsp, fmt, lint
        nodePackages.bash-language-server
        shfmt
        shellcheck
        # nix lanaguage
        pkgs.nil # nix language-server
        alejandra # nix 格式化工具
        allure # 测试报告生产工具
        taplo # toml 格式化工具
      ];
    }
  ]);
}
