{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.dev.java;
  asdf_bin = "${config.modules.dev.package}/bin/asdf";
in {
  options.modules.dev.java = with types; {
    enable = mkBoolOpt false;
    plugins = mkOption {
      description = "Use asdf to install java version";
      type = listOf (nullOr str);
      default = [];
    };
  };

  config = mkIf cfg.enable {
    modules.dev.plugins = ["java"];
    modules.shell.rcInit =
      if (cfg.plugins != [])
      then "_source ${config.my.hm.dataHome}/asdf/plugins/java/set-java-home.zsh"
      else "";
    modules.dev.pltext = optionalString (cfg.plugins != []) (asdfInPlugins asdf_bin "java" cfg.plugins);
  };
}
