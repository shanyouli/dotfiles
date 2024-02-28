{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell;
  getLastFunction = str: last (splitString "/" str);
  cmpFunction = l:
    concatMapAttrs (n: v: {
      "${n}".source = v;
    }) (builtins.listToAttrs (map (n: {
        name = "zsh/completions/${getLastFunction n}";
        value =
          if hasPrefix "/" n
          then n
          else "${config.dotfiles.configDir}/${n}";
      })
      l));
in {
  options.modules.shell = with types; {
    enZinit = mkBoolOpt false;
    enZoxide = mkBoolOpt false;
    enNavi = mkBoolOpt false;
    enVivid = mkBoolOpt false;
    aliases = mkOpt (attrsOf (either str path)) {};
    env = mkOption {
      type = attrsOf (oneOf [str path (listOf (either str path))]);
      apply = mapAttrs (n: v:
        if isList v
        then
          (
            if (strings.toUpper "${n}") == "PATH"
            then concatMapStringsSep " " toString v
            else concatMapStringsSep ":" toString v
          )
        else (toString v));
      default = {};
      description = "TODO";
    };
    rcInit = mkOpt' lines "" ''
      Zsh lines to be written to $XDG_CONFIG_HOME/zsh/extra.zshrc and sourced by
      $XDG_CONFIG_HOME/zsh/.zshrc
    '';
    envInit = mkOpt' lines "" ''
      Zsh lines to be written to $XDG_CONFIG_HOME/zsh/extra.zshenv and sourced
      by $XDG_CONFIG_HOME/zsh/.zshenv
    '';
    prevInit = mkOpt' lines "" "zshrc pre";
    rcFiles = mkOpt (listOf (either str path)) [];
    envFiles = mkOpt (listOf (either str path)) [];
    cmpFiles = mkOpt (listOf (either str path)) [];
  };

  # 一些现代命令行工具的推荐:https://github.com/ibraheemdev/modern-unix
  config = mkMerge [
    {
      # lib.mkIf cfg.enable (lib.mkMerge [{ users.defaultUserShell = pkgs.zsh; }]);
      # only nixos
      # users.defaultUserShell = pkgs.zsh;
      user.shell = pkgs.zsh;
      programs.zsh = {
        enable = true;
        # 我将自动启用bashcompinit 和compinit配置
        enableCompletion = false;
        enableBashCompletion = false;
        promptInit = "";
      };
      user.packages = with pkgs; [
        stable.bottom
        stable.fd
        stable.eza
        stable.bat
        stable.any-nix-shell
        stable.duf
        httrack # 网页抓取
        cachix # nix cache
        stable.hugo # 我的blog工具
        imagemagick # 图片转换工具
        gifsicle # 命令行gif生成工具

        stable.atool # 解压工具
        stable.gnused # sed 工具
        stable.coreutils-prefixed # GNUcoreutils 工具，mv，cp等
        (pkgs.sysdo.override {
          withZshCompletion = true;
          withRich = true;
        })

        tailspin # 支持高亮的语法查看工具
        nvfetcher-bin # 管理自己构建包的升级

        stable.fzf
        pkgs.my-nix-script
      ];
      env = {
        PATH = ["${config.home.binDir}"];
        ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
        ZSH_CACHE = "${config.home.cacheDir}/zsh";
      };
      modules.shell = {
        prevInit = ''
          # starship和p10有自己的提示方法；--info-right
          _cache ${pkgs.any-nix-shell}/bin/any-nix-shell zsh
          # FZF 配置
          FZF_DEFAULT_COMMAND="fd -H -I --type f"
          FZF_DEFAULT_OPTIONS="fd --height 50%"
          FZF_CTRL_T_COMMAND="fd -H -I --type f"
          FZF_CTRL_T_OPTS="--preview 'bat --color=always --plain --line-range=:200 {}'"
          FZF_ALT_C_COMMAND="fd -H -I --type d -E '.git*'"
          FZF_ALT_C_OPTS="--preview 'eza -T -L 2 {} | head -2000'"
          # FZF_CTRL_R_OPTS=""
          source ${pkgs.stable.fzf}/share/fzf/completion.zsh
          source ${pkgs.stable.fzf}/share/fzf/key-bindings.zsh
        '';
        aliases.htop = "btm --basic --mem_as_value";
        aliases.df = "duf";
        aliases.cat = "bat -p"; #or  bat -pp
        aliases.unzip = "atool --extract --explain";
        aliases.zip = "atool --add";
        aliases.log = "tspin";
      };

      home = {
        configFile =
          {
            # "bat/themes" = {
            #   source = "${config.dotfiles.configDir}/bat/themes";
            #   recursive = true;
            # };
            "zsh" = {
              source = "${config.dotfiles.configDir}/zsh";
              recursive = true;
            };
            "zsh/.zshrc".text = ''
              ${lib.optionalString (! cfg.enZinit) ''
                export ZINIT_HOME="''${XDG_DATA_HOME}/zinit/zinit.git"
                [[ -d "''${ZINIT_HOME}" ]] || {
                  mkdir -p $(dirname "''${ZINIT_HOME}")
                  git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "''${ZINIT_HOME}"
                }
              ''}
              _source "''${ZDOTDIR}/cache/prev.zshrc" \
                "''${ZDOTDIR}/zshrc.zsh" \
                "''${ZDOTDIR}/cache/extra.zshrc" \
                "~/.zshrc"
            '';
            "zsh/cache/prev.zshrc".text = ''${cfg.prevInit}'';
            "zsh/cache/extra.zshrc".text = let
              p10 =
                if config.modules.shell.starship.enable
                then "_cache starship init zsh --print-full-init"
                else ''
                  zinit ice depth=1
                  zinit light romkatv/powerlevel10k
                  if [[ "$INSIDE_EMACS" != 'vterm' ]]; then
                    _source $ZDOTDIR/p10conf/default.zsh
                  else
                    _source $ZDOTDIR/p10conf/vterm.zsh
                  fi
                '';
              aliasLines =
                mapAttrsToList (n: v: ''alias ${n}="${v}"'') cfg.aliases;
            in ''
              # This file was autogenerated, do not edit it!
              ${p10}
              ${concatMapStrings (path: ''
                  _dsource '${path}'
                '')
                cfg.rcFiles}
              ${concatStringsSep "\n" aliasLines}
              ${cfg.rcInit}
            '';
            "zsh/cache/extra.zshenv".text = let
              envLines =
                mapAttrsToList (n: v: (
                  if (strings.toUpper "${n}") == "PATH"
                  then ''export path=( ${v} $path)''
                  else ''export ${n}="${v}"''
                ))
                cfg.env;
            in ''
              # typeset -U path
              # if [ -n "$__MY_ZSHENV_SOURCED" ]; then return; fi
              # export __MY_ZSHENV_SOURCED=1
              # This file is autogenerated, do not edit it!
              ${concatStringsSep "\n" envLines}
              ${concatMapStringsSep "\n" (path: "_dsource '${path}' ") cfg.envFiles}
              ${cfg.envInit}
            '';
          }
          // (cmpFunction cfg.cmpFiles);
      };
    }
    (mkIf cfg.enZoxide {
      user.packages = [pkgs.zoxide];
      modules.shell.rcInit = ''
        _cache zoxide init zsh
      '';
    })
    (mkIf cfg.enNavi {
      user.packages = [pkgs.navi];
    })
    # 一个更好的LS_COLORS 工具: https://github.com/sharkdp/vivid
    (mkIf cfg.enVivid {
      user.packages = [pkgs.vivid];
    })
    (mkIf cfg.enZinit {
      user.packages = [pkgs.zinit];
      modules.shell.env.ZINIT_HOME = "${pkgs.zinit}/share/zinit";
    })
    (mkIf (! cfg.atuin.enable) {
      modules.shell.prevInit = ''
        _source "${config.dotfiles.configDir}/zsh/history.zsh"
      '';
    })
    (mkIf (! cfg.enVivid) {
      modules.shell.rcInit = ''
        # colors 配置 if'[[ -z $LS_COLORS ]]'
        zice 0a atcone="dircors -b LS_COLORS > c.zsh" \
          atpull='%atclone' pick='c.zsh' \
          trapd00r/LS_COLORS
      '';
    })
  ];
}
