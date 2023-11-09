{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.java;
in {
  options.my.modules.java = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    my.modules.asdf = {
      enable = true;
      plugins = ["java"];
    };
    my.modules.zsh.rcInit = "_source ${config.my.hm.dataHome}/asdf/plugins/java/set-java-home.zsh";
  };
}
