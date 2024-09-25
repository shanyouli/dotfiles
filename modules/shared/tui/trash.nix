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
  cfm = config.modules;
  cfg = cfm.trash;
in {
  options.modules.trash = {
    enable = mkEnableOption "Whether to trash by commoand line";
  };
  config = mkMerge [
    (mkIf (cfg.enable && pkgs.stdenvNoCC.isDarwin) {
      home.packages = [pkgs.darwin.trash];
      modules.shell.aliases.rm = "trash";
      modules.shell.aliases.rmi = "trash -F";
    })
    (mkIf (cfg.enable && pkgs.stdenvNoCC.isLinux) {
      home.packages = [pkgs.trashy];
      modules.shell.aliases = {
        rm = "trashy put";
        rmi = "trashy put";
        rml = "trashy list";
        rmda = "trashy empty --all";
        rmra = "trashy restore --all";
        rmr = "trashy list | fzf --multi | awk '{$1=$1;print}' | rev | cut -d ' ' -f1 | rev | xargs trashy restore --match=exact --force";
        rmd = "trashy list | fzf --multi | awk '{$1=$1;print}' | rev | cut -d ' ' -f1 | rev | xargs trashy empty --match=exact --force";
      };
    })
    (mkIf (! cfg.enable) {
      modules.shell.aliases.rmi = "rm -i";
    })
  ];
}
