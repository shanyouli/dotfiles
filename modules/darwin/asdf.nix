{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.macos.asdf;
  cfm = config.my.modules;
in {
  options.my.modules.macos.asdf = {enable = mkBoolOpt false;};

  config = mkIf cfg.enable {
    my.modules.asdf.enable = true;
    # asdf 安装依赖工具
    homebrew.brews = [
      "autoconf"
      "automake"
      "coreutils"
      "libtool"
      "libyaml"
      "openssl@3"
      "readline"
      "unixodbc"
    ];
    macos.userScript.initasdf = let
      pl = cfm.asdf;
    in {
      enable =
        if ((pl.plugins != []) || pl.withDirenv)
        then true
        else false;
      desc = "初始化 asdf";
      text = ''
        export ASDF_DATA_DIR=${cfm.zsh.env.ASDF_DATA_DIR}
        ${pl.text}
      '';
    };
  };
}
