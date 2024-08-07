{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.dev.python;
  cfg = cfp.rye;
  cpkg = pkgs.rye;
  cfb = "${cpkg}/bin/rye";
in {
  options.modules.dev.python.rye = {
    enable = mkEnableOption "Whether to use rye";
    manager = mkBoolOpt false; # 为 true时，使用 rye 管理 python 版本
  };
  config = mkIf cfg.enable (mkMerge [
    {
      user.packages = [cpkg pkgs.uv];
      modules.shell.direnv.stdlib.rye = pkgs.writeScript "rye" ''
        #!/usr/bin/env bash
        # 基本工作流程:
        # 1. ~rye init new-project~. 项目初始化，创建要给 pyproject.toml 文件,如果项目已存在则直接运行第二步
        # 2. ~cd new-project~
        # 3. ~touch .envrc && echo 'use rye' > .envrc~
        # 4. ~direnv allow~  将执行 ~rye sync~ 创建一个虚拟环境，并激活该虚拟环境
        # 5. 开始工作

        use_rye() {
            PYPROJECT_TOML="''${PYPROJECT_TOML:-pyproject.toml}"
            if [[ ! -f "''${PYPROJECT_TOML}" ]]; then
                log_status "No pyproject.toml found. Executing \`rye init\` to create a \`$PYPROJECT_TOML\` first."
                rye init
            fi

            if [[ -d ".venv" ]]; then
                VIRTUAL_ENV="$(pwd)/.venv"
            fi

            if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
                log_status "No virtual environment exists. Executing \`rye sync\` to create one."
                rye sync
                VIRTUAL_ENV="$(pwd)/.venv"
            fi

            PATH_add "$VIRTUAL_ENV/bin"
            export RYE_ACTIVE=1
            export VIRTUAL_ENV
        }
      '';
      modules.shell.env.RYE_HOME = "${config.home.dataDir}/rye";
      modules.shell.env.RYE_NO_AUTO_INSTALL = "1";
    }
    (mkIf (cfg.manager == false) {
      modules.dev.manager.extInit = let
        asdf_fn = v: "$(${config.modules.dev.manager.asdf.package}/bin/asdf where python ${v})";
        mise_fn = v: "$(${config.modules.dev.manager.mise.package}/bin/mise where python@${v})";
        use_fn =
          if config.modules.dev.manager.default == "mise"
          then mise_fn
          else asdf_fn;
        base_fn = v: ''
          if ! ${cfb} toolchain list | grep ${use_fn v} >/dev/null 2>&1; then
            echo-info "rye Register python version ${v}"
            ${cfb} toolchain register ${use_fn v}/bin/python
          fi
        '';
        ver_fn =
          if builtins.isString cfp.versions
          then ''
            ${base_fn cfp.versions}
          ''
          else if builtins.elem cfp.versions [null [] true false]
          then ''''
          else concatStrings (map base_fn cfp.versions);
      in ''
        echo-info "Rye: Registering an existing python to rye management."
        export RYE_HOME="${config.home.dataDir}/rye"
        ${ver_fn}
      '';
    })
  ]);
}
