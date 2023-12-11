{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.java;
in {
  options.modules.java = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    modules.asdf = {
      enable = true;
      plugins = ["java"];
    };
    modules.zsh.rcInit = "_source ${config.my.hm.dataHome}/asdf/plugins/java/set-java-home.zsh";
  };
}
