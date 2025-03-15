{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  inherit (my) homedir;
in {
  options = with types; {
    env = mkOption {
      type = attrsOf (oneOf [str path (listOf (either str path))]);
      apply = mapAttrs (_n: v:
        if isList v
        then concatMapStringsSep ":" toString v
        else (toString v));
      default = {};
      description = "Configuring System Environment Variables";
    };
    home = {
      configFile = mkOpt' attrs {} "Files to place directly in $XDG_CONFIG_HOME";
      dataFile = mkOpt' attrs {} "Files to place in $XDG_CONFIG_HOME";
      fakeFile = mkOpt' attrs {} "Files to place in $XDG_FAKE_HOME";

      dataDir = mkOpt' path "${homedir}/.local/share" "xdg_data_home";
      stateDir = mkOpt' path "${homedir}/.local/state" "xdg_state_home";
      binDir = mkOpt' path "${homedir}/.local/bin" "xdg_bin_home";
      configDir = mkOpt' path "${homedir}/.config" "xdg_config_home";
      cacheDir = mkOpt' path "${homedir}/.cache" "xdg_cache_home";
      fakeDir = mkOpt' path "${homedir}/.local/user" "Fake Home";

      services = mkOpt' attrs {} "home-manager user script";
      # 系统级使用 nix 是指: 使用 darwin-rebuild 或 nixos-rebuild 管理
      # 用户级使用 nix 是指: 使用 home-manager 管理
      useos = mkOpt' bool false "系统级使用 nix 还是用户级使用 nix";

      programs = mkOpt' attrs {} "home-manager programs";
      initScript = mkPkgReadOpt "初始化用户脚本";
      initExtra = mkOpt' lines "" "激活时，需要执行 nu 代码"; # nushell 语言
    };
  };
  config = {
    home.initScript = writeNuScript' {
      name = "init-user";
      text = ''
        use std log
        print $"(ansi green_bold)Init user script commands...(ansi reset)"
        ${config.home.initExtra}
      '';
      nushell =
        if config.modules.shell.nushell.enable
        then config.modules.shell.nushell.package
        else pkgs.nushell;
    };
    # documentation.man.enable = mkDefault true;
    nix = {
      # envVars = {
      #   https_proxy = "http://127.0.0.1:7890";
      #   http_proxy = "http://127.0.0.1:7890";
      #   all_proxy = "http://127.0.0.1:7890";

      # };
      package = mkDefault pkgs.nix;
      gc = {
        # 如果使用 nh 进行 gc，请不要使用 nix.gc.automatic, 二者冲突了。
        # automatic = mkDefault (!(config.modules.nh.clean.enable && config.modules.nh.enable));
        automatic = mkDefault true;
        # automatic = mkDefault (!(config.modules.nh.clean.enable && config.modules.nh.enable));
        options = mkDefault "--delete-older-than 7d";
      };
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
      '';
      settings = let
        users = ["root" my.user "@admin" "@wheel"];
      in {
        trusted-users = users;
        allowed-users = users;
        max-jobs = 4;
        substituters = pkgs.lib.mkBefore [
          # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          # "https://mirror.sjtu.edu.cn/nix-channels/store"
          # "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://shanyouli.cachix.org"
        ];
        # Using hard links
        # a BUG: about darwin see@https://github.com/NixOS/nix/issues/7273
        auto-optimise-store = mkDefault (
          if pkgs.stdenvNoCC.isDarwin
          then false
          else true
        );
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "shanyouli.cachix.org-1:19ndCE7zQfn5vIVLbBZk6XG0D7Ago7oRNNgIRV/Oabw="
        ];
      };
    };
  };
}
