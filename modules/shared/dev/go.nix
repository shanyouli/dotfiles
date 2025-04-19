{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.dev;
  cfg = cfp.go;
in
{
  options.modules.dev.go = {
    enable = mkEnableOption "Whether to Go Language";
    versions = mkOption {
      description = "Use dev-manager to install go version";
      type =
        with types;
        oneOf [
          str
          (nullOr bool)
          (listOf (nullOr str))
        ];
      default = [ ];
    };
    global = mkOption {
      description = "Go default version";
      type = str;
      default = "";
      apply =
        s:
        if builtins.isString cfg.versions then
          cf.versions
        else if (builtins.isList cfg.versions) && ((builtins.length cfg.versions) > 0) then
          (if (builtins.elem s cfg.versions) then s else builtins.head cfg.versions)
        else
          "";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        # goimports, godoc, etc.
        gotools

        # https://github.com/golangci/golangci-lint
        golangci-lint
        gopls
      ];
      modules.shell.env.GOPROXY = "https://proxy.golang.com.cn,direct";
    }
    (mkIf (cfg.versions == [ ] || cfg.global == "") {
      home.packages = [ pkgs.go ];
      modules.shell = {
        fish.prevInit = "set -gx PATH (string replace -r '://bin:' '' $GOPATH)/bin $PATH";
        zsh.prevInit = ''export PATH=''${GOPATH//://bin:}/bin:$PATH'';
      };
      env = {
        GOPATH = "$XDG_DATA_HOME/go";
      };
    })
    (mkIf (cfg.versions != [ ]) {
      modules = {
        dev = {
          lang.go = cfg.versions;
          manager.extInit = lib.optionalString (cfg.global != "") ''
            ${lib.optionalString (config.modules.dev.manager.default == "asdf") (
              let
                asdfbin = "${config.modules.dev.manager.asdf.package}/bin/asdf";
              in
              ''
                echo-info "go global version ${cfg.global}"
                ${asdfbin} global go ${cfg.global}
              ''
            )}
            ${lib.optionalString (config.modules.dev.manager.default == "mise") (
              let
                misebin = "${config.modules.dev.manager.mise.package}/bin/mise";
              in
              ''
                echo-info "go version version ${cfg.global}"
                ${misebin} global -q go@${cfg.global}
              ''
            )}
          '';
        };
      };
    })
  ]);
}
