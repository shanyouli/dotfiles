{
  config,
  pkgs,
  ...
}: {
  # user.name = "lyeli";
  nix = {
    gc = {user = config.my.username;};
    # Auto upgrade nix package and the daemon service.
    # services.nix-daemon.enable = true;
    # nix.package = pkgs.nix;
    # maxJobs = 4;
    settings.cores = 4;
  };

  my = {
    terminal = "kitty";
    modules = {
      macos.enable = true;
      macos.stopAutoReopen = true;
      macos.clash.enable = true;
      macos.clash.configFile = "${config.my.hm.dir}/Nutstore Files/我的坚果云/clash/meta.yaml";
      macos.music.enable = true;
      macos.games.enable = true;
      macos.yabai.enable = true;
      macos.emacs.enable = true;
      macos.emacs.serverEnable = true;
      macos.aria2.enable = true;
      macos.hammerspoon.enable = true;
      macos.alist.enable = true;
      macos.mpd.enable = true;
      macos.rime.enable = true;
      macos.iina.enable = true;
      macos.battery.enable = true;
      macos.asdf.enable = true;
      asdf.withDirenv = true;
      firefox.package = pkgs.firefox-esr-bin;
      macos.brew.mirror = "tuna";
      macos.nginx.enable = true;
      # macos.mosdns.enable                  = true;
      # mail                                 = { enable = true; };
      # aerc                                 = { enable = true; };
      # irc.enable                           = true;
      # rescript.enable                      = false;
      # clojure.enable                       = true;
      gpg.enable = true;
      gpg.cacheTTL = 36000;
      # discord.enable                       = true;
      # hledger.enable                       = true;
      adb.enable = true;
    };
    # https://github.com/LnL7/nix-darwin/issues/214#issuecomment-1230730292
    # hm.file."Applications/Myapps" = let
    #   app = pkgs.buildEnv {
    #     name = "my-manager-applications";
    #     paths = config.my.user.packages ++ config.my.hm.pkgs;
    #     pathsToLink = "/Applications";
    #   };
    # in { source = "${app}/Applications"; };
  };

  networking = {hostName = "home-box";};
  macos.userScript.setingApplications = {
    enable = true;
    desc = "My method is used to manage applications";
    text = let
      apps = pkgs.buildEnv {
        name = "my-manager-applications";
        paths = config.my.user.packages ++ config.my.hm.pkgs;
        pathsToLink = "/Applications";
      };
    in ''
      echo "remove Home Manager Generation link"
      if [[ -L "$HOME/Applications/Home Manager Apps"  ]]; then
        $DRY_RUN_CMD rm -rf "$HOME/Applications/Home Manager Apps"
      fi

      echo "setting up ~/Applications/Myapps..." >&2
      nix_apps="$HOME/Applications/Myapps"
      nix_apps_linktxt="$nix_apps/.appslink.txt"
      nix_apps_rmdir=$(mktemp -d)

      # echo $nix_apps_rmdir

      # Delete the directory to remove old links
      # $DRY_RUN_CMD rm -rf "$nix_apps"
      if ! [[ -d $nix_app ]]; then
         $DRY_RUN_CMD mkdir -p "$nix_apps"
      fi

      old_apps=( $nix_apps/* )
      new_apps=( ${apps}/Applications/* )
      if [[ "''${old_apps[*]}" != "$nix_apps/*" ]]; then
        for i in "''${old_apps[@]}"; do
          result=false
          for k in "''${new_apps[@]}"; do
            if [[ $(basename "$i") == $(basename "$k") ]]; then
              result=true
              break
            fi
          done
          if [[ $result == false ]]; then
            $DRY_RUN_CMD mv -f "$i" $nix_apps_rmdir
          fi
        done
      fi

      _sys_apps=()
      while IFS= read -r line; do
        _sys_apps+=("$line")
      done <<< "$(find ${apps}/Applications -maxdepth 1 -type l -exec readlink '{}' \; )"

      # echo ''${_sys_apps[@]}
      # readarray -t _sys_apps <<< "$(find ${apps}/Applications -maxdepth 1 -type l -exec readlink '{}' \; )"
      if [[ -f "''${nix_apps_linktxt}" ]]; then
        for _app in "''${_sys_apps[@]}"; do
          # echo $_app
          base_name="$(basename "$_app")"
          if ! grep -q "$_app" "''${nix_apps_linktxt}" >/dev/null; then
            if [[ -d "$nix_apps/$base_name" ]]; then
              chmod -R +w "$nix_apps/$base_name"
              $DRY_RUN_CMD mv -f "$nix_apps/$base_name" $nix_apps_rmdir
              echo "update $base_name"
            else
              echo "install newApp: $base_name"
            fi
            $DRY_RUN_CMD cp  -r "$_app" $nix_apps
          else
            if ! [[ -d "$nix_apps/$base_name" ]]; then
              echo "Reinstall $base_name"
              $DRY_RUN_CMD cp -r "$_app" "$nix_apps"
            fi
          fi
        done
      else
        for _app in "''${_sys_apps[@]}"; do
          echo "install newApp: $(basename "$_app")"
          $DRY_RUN_CMD cp -r "$_app" $nix_apps
        done
      fi

      chmod -R u+w $nix_apps/*
      $DRY_RUN_CMD rm -rf "''${nix_apps_linktxt}"
      for _app in "''${_sys_apps[@]}"; do
        $DRY_RUN_CMD echo "$_app" >> "''${nix_apps_linktxt}"
      done
      # if [[ -d $nix_apps_rmdir ]]; then
      #   chmod -R +w $nix_apps_rmdir
      #   $DRY_RUN_CMD rm -rf $nix_apps_rmdir
      # fi
    '';
  };
  # 如果你想使用macos别名请查看
  # https://github.com/LnL7/nix-darwin/issues/139#issuecomment-1230728610
  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config =$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig                 = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild chang/nix/store/6xnavkbxd3kkkyssqds9p9rw9r47cj1q-gnupg-2.4.1/bin/gpg-connect-agentelog
  system.stateVersion = 4;
}
