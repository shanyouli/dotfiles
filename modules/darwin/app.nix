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
        ++ (optionals (config.my.hm ? pkgs) config.my.hm.pkgs)
        ++ config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in {
    # https://github.com/LnL7/nix-darwin/issues/214#issuecomment-1230730292
    # hm.file."Applications/Myapps" = let
    #   app = pkgs.buildEnv {
    #     name = "my-manager-applications";
    #     paths = config.user.packages ++ config.my.hm.pkgs;
    #     pathsToLink = "/Applications";
    #   };
    # in { source = "${app}/Applications"; };
    macos.userScript.settingApplications = {
      enable = true;
      desc = "My method is used to manage applications";
      text = ''
        if [[ -L "$HOME/Applications/Home Manager Apps"  ]]; then
           echo "remove Home Manager Generation link"
          $DRY_RUN_CMD rm -rf "$HOME/Applications/Home Manager Apps"
        fi
        echo "settings up ${workdir}..." >&2
        nix_apps="${workdir}"
        nix_app_linktxt="$nix_apps/.appslist.txt"
        nix_apps_tmpdir=$(mktemp -d)

        [[ -d $nix_apps ]] || $DRY_RUN_CMD mkdir -p "$nix_apps"

        new_apps=( ${apps}/Applications/* )

        _first_add_app() {
          for _app in "''${new_apps[@]}" ; do
            echo "install newApp: $(basename "$_app")"
            local capp_path="$(readlink -f "$_app")"
            $DRY_RUN_CMD cp -r "$capp_path" $nix_apps
            echo $capp_path >> $nix_app_linktxt
          done
        }
        _second_add_app() {
          local _tmp="$nix_apps_tmpdir/.appslist.txt"
          for _app in "''${new_apps[@]}" ; do
            local _app_name="$(basename "$_app")"
            local _app_grep_by="$(grep "$_app_name" "$_tmp")"
            local _app_readlink_path="$(readlink -f "$_app")"

            if [[ -n $_app_grep_by ]]; then
              if [[ "$_app_grep_by" != "$_app_readlink_path" ]]; then
                local old_app_path="$nix_apps/$_app_name"
                if [[ -e $old_app_path ]]; then
                  chmod -R +w "$old_app_path"
                  $DRY_RUN_CMD mv -f "$old_app_path" $nix_apps_tmpdir
                fi
                echo "Update app: $_app_name ..."
                $DRY_RUN_CMD cp -r "$_app_readlink_path" $nix_apps
              fi
              sed -i'.bak' "\:$_app_grep_by:d" $_tmp
            else
              echo "Install newApp: $_app_name ..."
              $DRY_RUN_CMD cp -r "$_app_readlink_path" $nix_apps
            fi
            echo "$_app_readlink_path" >> $nix_app_linktxt
          done
          while IFS= read -r line; do
            local app_name="$(echo "$line" | awk -F/ '{print $(NF)}')"
            local old_app_path="$nix_apps/$app_name"
            if [[ -e $old_app_path ]]; then
              echo "Remove app: $app_name"
              chmod -R +w "$old_app_path"
              $DRY_RUN_CMD mv -f "$old_app_path" $nix_apps_tmpdir
            fi
          done < "$_tmp"
        }
        _apps_init() {
          if [[ "''${new_apps[*]}" != "${apps}/Applications/*" ]]; then
            if [[ -f $nix_app_linktxt ]]; then
              chmod u+w $nix_app_linktxt
              $DRY_RUN_CMD mv -f $nix_app_linktxt $nix_apps_tmpdir
              _second_add_app
            else
              _first_add_app
            fi
          fi
        }
        _apps_init
        chmod a-w $nix_app_linktxt
        chmod -R u+w $nix_apps/*
        ${optionalString (cfg.enBackup == false) ''
          if [[ -d $nix_apps_rmdir ]]; then
            chmod -R +w $nix_apps_rmdir
            $DRY_RUN_CMD rm -rf $nix_apps_rmdir
          fi
        ''}
        unset nix_apps nix_app_linktxt nix_apps_tmpdir new_apps
      '';
    };
  });
}
