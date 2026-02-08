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
  inherit (my) homedir;
  makeNuScript =
    name: x:
    let
      filterEnabledTexts =
        dict:
        let
          dict-list = mapAttrsToList (
            name: value:
            (
              if builtins.isString value then
                {
                  desc = name;
                  level = 50;
                  text = value;
                  enable = true;
                }
              else
                {
                  inherit (value) text;
                  desc = value.desc or name;
                  level = value.level or 50;
                  enable = value.enable or true;
                }
            )
          ) dict;
          sortFn = la: sort (x: y: x.level <= y.level) la;
        in
        concatMapStrings (x: ''
          log tip ${x.desc}
          ${x.text}
        '') (sortFn (filter (x: x.enable) dict-list));
      text = ''
        use std log
        $env.NU_LOG_FORMAT = "%ANSI_START%%LEVEL%: %MSG%%ANSI_STOP%"
        let log_level = log log-level | get INFO
        let term_col = term size | get columns
        def tip [--end (-e), ...msg] {
          let msg_str = $msg | str join " "
          if $end {
            let msg_str = $" ($msg_str), END " | fill --alignment c --character "-" --width $term_col
            log custom -a (ansi blue_dimmed) $msg_str "%ANSI_START%%MSG%%ANSI_STOP%" $log_level
          } else {
            let msg_str = $" ($msg_str), BEGIN " |  fill --alignment c --character "-" --width $term_col
            log custom -a (ansi blue_bold) $msg_str "%ANSI_START%%MSG%%ANSI_STOP%" $log_level
          }
        }
        def "log t" [--end (-e), ...msg] {
          let msg_str = $msg | str join " "
          if $end {
            let msg_str = $" ($msg_str), END " | fill --alignment c --character "=" --width $term_col
            log custom -a (ansi blue_dimmed) $msg_str "%ANSI_START%%MSG%%ANSI_STOP%" $log_level
          } else {
            let msg_str = $" ($msg_str), BEGIN " |  fill --alignment c --character "=" --width $term_col
            log custom -a (ansi blue_bold) $msg_str "%ANSI_START%%MSG%%ANSI_STOP%" $log_level
          }
        }

        $env.__counter = 1

        def --env "log tip" [--end(-e), ...msg] {
          if $end {
            log custom -a (ansi green_dimmed) "}}}\n" "%ANSI_START%%MSG%%ANSI_STOP%" $log_level
          } else {
            let current_count = $env.__counter | fill --alignment r --width 2 -c "0"
            let msg_str = $msg | str join " " | $"Tips ($current_count): ($in) >>>"
            log custom -a (ansi green_bold) $msg_str "%ANSI_START%%MSG%%ANSI_STOP%" $log_level
            $env.__counter += 1
          }
        }
        log set-level 10
        tip "Init ${name} script commands"
        log debug $"The script file path is ($env.CURRENT_FILE)"
        ${optionalString (x.pre != "") ''
          log t Priority activation section
          ${x.pre}
          log t -e Priority activation section
        ''}
        log t Execution of parts in order of need
        ${filterEnabledTexts x.init}
        log t -e Execution of parts in order of need
        ${optionalString (x.extra != "") ''
          log t Finally, execute the command
          ${x.extra}
          log t -e Finally, execute the command
        ''}

        tip -e "Init ${name} script commands"
      '';
      nushell =
        if config.modules.shell.nushell.enable then config.modules.shell.nushell.package else pkgs.nushell;
    in
    writeNuScript' { inherit name text nushell; };
in
{
  options = with types; {
    env = mkOption {
      type = attrsOf (oneOf [
        str
        path
        (listOf (either str path))
      ]);
      apply = mapAttrs (_n: v: if isList v then concatMapStringsSep ":" toString v else (toString v));
      default = { };
      description = "Configuring System Environment Variables";
    };
    # 用来执行自己编写的需要在构建系统时，执行的配置。
    my = {
      user = {
        script = mkPkgReadOpt "初始化用户 nushell 脚本。";
        extra = mkOpt' lines "" "激活时，运行的额外 nu 代码.";
        pre = mkOpt' lines "" "激活系统时，先执行的 nu 代码.";
        # init 的 key 的 values 类型有 string，attrs
        # 当 values 为 attrs 时， 可用 key:
        # - level 代码优先级
        # - enable 是否加载代码
        # - text 代码
        # - desc 描述
        init = mkOpt' attrs { } "激活时执行的 nu 代码.";
      };
      # like user,但是执行的代码需要 root 权限。 暂时不支持 home-manager
      system = {
        script = mkPkgReadOpt "初始化system nushell 脚本。";
        extra = mkOpt' lines "" "激活时，运行的额外 nu 代码.";
        pre = mkOpt' lines "" "激活系统时，先执行的 nu 代码.";
        init = mkOpt' attrs { } "激活时执行的 nu 代码.";
      };
    };
    home = {
      configFile = mkOpt' attrs { } "Files to place directly in $XDG_CONFIG_HOME";
      dataFile = mkOpt' attrs { } "Files to place in $XDG_CONFIG_HOME";
      fakeFile = mkOpt' attrs { } "Files to place in $XDG_FAKE_HOME";

      dataDir = mkOpt' path "${homedir}/.local/share" "xdg_data_home";
      stateDir = mkOpt' path "${homedir}/.local/state" "xdg_state_home";
      binDir = mkOpt' path "${homedir}/.local/bin" "xdg_bin_home";
      configDir = mkOpt' path "${homedir}/.config" "xdg_config_home";
      cacheDir = mkOpt' path "${homedir}/.cache" "xdg_cache_home";
      fakeDir = mkOpt' path "${homedir}/.local/user" "Fake Home";

      services = mkOpt' attrs { } "home-manager user script";
      # 系统级使用 nix 是指: 使用 darwin-rebuild 或 nixos-rebuild 管理
      # 用户级使用 nix 是指: 使用 home-manager 管理
      useos = mkOpt' bool false "系统级使用 nix 还是用户级使用 nix";
      programs = mkOpt' attrs { } "home-manager programs";
    };
  };
  config = {
    my = {
      user.script = makeNuScript "user" config.my.user;
      system.script = makeNuScript "system" config.my.system;
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
      settings =
        let
          users = [
            "root"
            my.user
            "@admin"
            "@wheel"
          ];
        in
        {
          trusted-users = users;
          allowed-users = users;
          max-jobs = 4;
          substituters = pkgs.lib.mkBefore [
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
            # "https://mirrors.ustc.edu.cn/nix-channels/store"
            # "https://.sjtu.edu.cn/nix-channels/store"
            # "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://shanyouli.cachix.org"
          ];
          # Using hard links
          # a BUG: about darwin see@https://github.com/NixOS/nix/issues/7273
          auto-optimise-store = mkDefault (!pkgs.stdenvNoCC.isDarwin);
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "shanyouli.cachix.org-1:19ndCE7zQfn5vIVLbBZk6XG0D7Ago7oRNNgIRV/Oabw="
          ];
        };
    };
  };
}
