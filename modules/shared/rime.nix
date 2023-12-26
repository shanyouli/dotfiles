{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.rime;
  cfm = config.modules;
  # 移除 home目录后的部分
  useEmacs = cfm.editor.emacs.enable && cfm.editor.emacs.rimeEnable;
in {
  options.modules.rime = {
    enable = mkBoolOpt false;
    backupDir =
      mkOpt' types.path "${config.my.workdir}/rime-bak" "rime 词库同步文件";
    userDir =
      mkOpt' types.path "${config.user.home}/.config/fcitx/rime"
      "rime 用户文件保存位置";
    script = mkOpt' types.str "" "执行脚本";
    extraScript = mkOpt' types.lines "" "额外的执行内容";
    backupid = mkOpt' types.str "" "rime 同步id";
    ice = {
      enable = mkBoolOpt true;
      dir = mkOpt' types.path "${config.my.workdir}/rime-ice" "保存雾凇拼音仓库位置";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      modules.rime.script = let
        rimedir = cfg.userDir;
      in ''
        if [[ ! -d ${rimedir} ]]; then
          mkdir -p ${rimedir}
        fi

        ${optionalString cfg.ice.enable ''
          repoUpdir=$(dirname ${cfg.ice.dir})
          if [[ ! -d $repoUpdir ]]; then
            mkdir -p $repoUpdir
          fi

          ${optionalString useEmacs ''
            if [[ ! -d ${config.my.hm.configHome}/emacs-rime ]]; then
              mkdir -p ${config.my.hm.configHome}/emacs-rime
            fi
          ''}
          echo ${cfg.ice.dir}
          if [[ ! -d ${cfg.ice.dir} ]]; then
            git clone --depth 1 https://github.com/iDvel/rime-ice.git ${cfg.ice.dir}
            for i in ${cfg.ice.dir}/* ; do
              ln -sf $i ${rimedir}/
              ${optionalString useEmacs "ln -sf $i ${config.my.hm.configHome}/emacs-rime/"}
            done
          fi
        ''}
        function changeRimeSync() {
          rimeCin="1"
          if [[  -f $1/installation.yaml ]]; then
            if [[ $(cat $1/installation.yaml | grep "sync_dir") =~ "$2" ]] && \
              [[ $(cat $1/installation.yaml | grep "installation_id") =~ "$3" ]]
            then
              echo "No Need change.."
            else
              rm -rf $1/installation.yaml
              rimeCin="0"
            fi
          else
            rimeCin="0"
          fi
          if [[ $rimeCin = "0" ]]; then
            echo "sync_dir: \"$2\"" > $1/installation.yaml
            echo "installation_id: \"$3\"" >> $1/installation.yaml
          fi
        }
        changeRimeSync ${rimedir} ${cfg.backupDir} ${cfg.backupid}
        ${optionalString useEmacs ''
          changeRimeSync ${config.my.hm.configHome}/emacs-rime ${cfg.backupDir} "emacs-rime"
        ''}
        ${cfg.extraScript}
      '';
    }
    (mkIf useEmacs {
      my.hm.configFile."emacs-rime/default.custom.yaml".source = "${configDir}/rime/default.custom.yaml";
    })
  ]);
}
