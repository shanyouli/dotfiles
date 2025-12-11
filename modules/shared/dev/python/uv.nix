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
  cfp = config.modules.dev.python;
  cfg = cfp.uv;
in
{
  options.modules.dev.python.uv = {
    enable = mkEnableOption "Whether to use uv";
    manager = mkBoolOpt cfg.enable; # 为 true时，使用 uv 管理 python 版本.
    package = mkPackageOption pkgs.unstable "uv" { };
  };
  config = mkIf cfg.enable (mkMerge [
    { home.packages = [ cfg.package ]; }
    (mkIf cfg.manager {
      assertions = [
        {
          assertion = !cfp.rye.manager;
          message = "Do not use rye and uv to manage python versions at the same time.";
        }
      ];
      modules = {
        python.pipx.enable = mkDefault false;
        dev.manager.extInit = mkAfter (
          let
            cfb = lib.getExe cfg.package;
            global_python_msg = optionalString (cfp.global != "") ''
              log info "Setting python global version ${cfp.global}"
              ${cfb} python install --default --preview "${cfp.global}"
            '';
            uv_install_fn = v: ''
              log info "uv python install ${v}"
              ${cfb} python install "${v}"
            '';
            version_msg =
              if builtins.isString cfp.versions then
                uv_install_fn cfp.versions
              else if
                (builtins.elem cfp.versions [
                  null
                  false
                  true
                  [ ]
                ])
              then
                ""
              else
                concatMapStrings uv_install_fn cfp.versions;
          in
          ''
            ${global_python_msg}
            ${version_msg}
          ''
        );
      };
    })
  ]);
}
