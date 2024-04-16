{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.macos.app;
in {
  options.modules.macos.app = {
    enable = mkEnableOption "Whether or not to connect the position.";
    name = mkOpt' types.str "Myapps" "存放位置目录名";
    enUser = mkBoolOpt true;
    enBackup = mkBoolOpt true;
    path = mkOpt' (types.nullOr types.path) null "不要修改它";
  };
  config = mkIf cfg.enable (let
    workdir =
      if cfg.enUser
      then "${config.user.home}/Applications/${cfg.name}"
      else "/Applications/${cfg.name}";
    apps = pkgs.buildEnv {
      name = "my-manager-applications";
      paths =
        config.user.packages
        ++ config.home.packages
        ++ config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in {
    modules.macos.app.path = workdir;
    # see @https://github.com/LnL7/nix-darwin/issues/214#issuecomment-1230730292
    # home.file."Applications/Myapps" = { source = "${apps}/Applications"; };
    # see @https://github.com/andreykaipov/nix/blob/384292d67c76b4a0df2308f51f8eb39abb36725c/.config/nix/packages/default.nix#L35-L64
    macos.userScript.settingApplications = {
      enable = true;
      desc = "My method is used to manage applications";
      text = ''
        if [[ -L "$HOME/Applications/Home Manager Apps"  ]]; then
          echo "remove Home Manager Generation link"
          $DRY_RUN_CMD rm -rf "$HOME/Applications/Home Manager Apps"
        fi
        echo "settings up ${workdir}..." >&2
        [[ -d "${workdir}" ]] || $DRY_RUN_CMD mkdir -p "${workdir}"

        apps_backup_dir=$(mktemp -d)
        function app_back_fn() {
            chmod -R +w "$1"
            $DRY_RUN_CMD mv -f "$1" "$apps_backup_dir"
        }

        function delete_apps_no_control() {
            local p1="$1"
            local p2="$2"
            cd "$p1" || exit 0
            find . -maxdepth 1 -iname "*.app"  | while read -r f; do
                if [[ ! -e "$p2/$f" ]]; then
                    echo-info "Uninstall: $(basename "$f")"
                    app_back_fn "$p1/$f"
                fi
            done
        }
        function hashApp() {
            local _path="$1/Contents/MacOS"; shift
            [[ -d "$_path" ]] && cd "$_path" || exit 0
            find . -perm +111 -type f -maxdepth 1 2>/dev/null | while read -r f; do
                md5sum "$_path/$f" | cut -b-32
            done | md5sum | cut -b-32
        }

        function apps_install() {
            local from_p1="$1"
            local to_p2="$2"
            cd "$from_p1" || exit 0
            find . -maxdepth 1 -iname "*.app" | while read -r f; do
                local f_readlink=$(readlink -f "$f")
                if [[ -e "$to_p2/$f" ]]; then
                    if [[ $(hashApp "$f_readlink") != $(hashApp "$to_p2/$f") ]]; then
                        echo-info "Update $(basename "$f")"
                        app_back_fn "$to_p2/$f"
                        $DRY_CMD_RUN cp -R "$f_readlink" "$to_p2"
                    fi
                else
                    echo-info "Install $(basename "$f")"
                    $DRY_CMD_RUN cp -R "$f_readlink" "$to_p2"
                fi
            done
        }
        delete_apps_no_control "${workdir}" "${apps}/Applications"
        apps_install "${apps}/Applications" "${workdir}"
        rmdir "$apps_backup_dir"  >/dev/null 2>&1 || {
        ${
          if cfg.enBackup
          then ''echo-info "Deleted or updated previous apps are stored in the $apps_backup_dir directory"''
          else ''
            chmod -R +w $apps_backup_dir
            $DRY_RUN_CMD rm -rf $apps_backup_dir
            echo-warn "Delete all apps before they are uninstalled or updated!!"
          ''
        }
        }
        unset apps_install apps_backup_dir hashApp app_back_fn delete_apps_no_control
      '';
    };
  });
}
