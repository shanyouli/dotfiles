{ config, pkgs, lib, ... }:
let
  functions = builtins.readFile ./functions.sh;
  useSkim = false;
  useFzf = !useSkim;
  fuzz = let fd = "${pkgs.fd}/bin/fd";
  in rec {
    defaultCommand = "${fd} -H --type f";
    defaultOptions = [ "--height 50%" ];
    fileWidgetCommand = "${defaultCommand}";
    fileWidgetOptions = [
      "--preview '${pkgs.bat}/bin/bat --color=always --plain --line-range=:200 {}'"
    ];
    changeDirWidgetCommand = "${fd} --type d";
    changeDirWidgetOptions =
      [ "--preview '${pkgs.tree}/bin/tree -C {} | head -200'" ];
    historyWidgetOptions = [ ];
  };
  aliases = lib.mkIf pkgs.stdenvNoCC.isDarwin {
    # darwin specific aliases
    ibrew = "arch -x86_64 brew";
    abrew = "arch -arm64 brew";
  } // {
    paria2 = "aria2c --all-proxy=http://127.0.0.1:7890";
  };
in {
  home.packages = [ pkgs.tree pkgs.yt-dlp  pkgs.sdcv ];
  programs = {
    ssh = {
      enable = true;
      includes = [ "config.d/*" ];
      forwardAgent = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      stdlib = ''
        # stolen from @i077; store .direnv in cache instead of project dir
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
            echo "''${direnv_layout_dirs[$PWD]:=$(
                echo -n "${config.xdg.cacheHome}"/direnv/layouts/
                echo -n "$PWD" | shasum | cut -d ' ' -f 1
            )}

        }

        layout_poetry() {
          if [[ ! -f pyproject.toml ]]; then
            log_error 'No pyproject.toml found. Use `poetry new` or `poetry init` to create one first.'
            exit 2
          fi

          # create venv if it doesn't exist
          poetry run true

          export VIRTUAL_ENV=$(poetry env info --path)
          export POETRY_ACTIVE=1
          PATH_add "$VIRTUAL_ENV/bin"
        }
      '';
    };
    skim = {
      enable = useSkim;
      enableBashIntegration = useSkim;
      enableZshIntegration = useSkim;
      enableFishIntegration = useSkim;
    } // fuzz;
    fzf = {
      enable = useFzf;
      enableBashIntegration = useFzf;
      enableZshIntegration = useFzf;
      enableFishIntegration = useFzf;
    } // fuzz;
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        color = "always";
      };
    };
    jq.enable = true;
    htop.enable = true;
    gpg.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      aliases = {
        ignore =
          "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
      };
    };
    go.enable = true;
    exa = {
      enable = true;
      enableAliases = true;
    };
    bash = {
      enable = true;
      shellAliases = aliases;
      initExtra = ''
        ${functions}
      '';
    };
    nix-index.enable = true;
    password-store = {
      enable = true; # 使用 pass 管理自己的密码
      package = pkgs.gopass;
    };
    zsh = let
      mkZshPlugin = { pkg, file ? "${pkg.pname}.plugin.zsh" }: rec {
        name = pkg.pname;
        src = pkg.src;
        inherit file;
      };
    in {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      localVariables = {
        LANG = "en_US.UTF-8";
        GPG_TTY = "/dev/ttys000";
        DEFAULT_USER = "${config.home.username}";
        CLICOLOR = 1;
        LS_COLORS = "ExFxBxDxCxegedabagacad";
        TERM = "xterm-256color";
      };
      shellAliases = aliases;
      initExtraBeforeCompInit = ''
        fpath+=~/.zfunc
      '';
      initExtra = ''
        ${functions}
        unset RPS1
      '';
      profileExtra = ''
        ${lib.optionalString pkgs.stdenvNoCC.isLinux
        "[[ -e /etc/profile ]] && source /etc/profile"}
      '';
      plugins = with pkgs; [
        (mkZshPlugin { pkg = zsh-autopair; })
        (mkZshPlugin { pkg = zsh-completions; })
        (mkZshPlugin { pkg = zsh-autosuggestions; })
        (mkZshPlugin {
          pkg = zsh-fast-syntax-highlighting;
          file = "fast-syntax-highlighting.plugin.zsh";
        })
        (mkZshPlugin { pkg = zsh-history-substring-search; })
      ];
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" ];
      };
      envExtra = ''
        ${lib.optionalString pkgs.stdenvNoCC.isDarwin ''
          if [[ -d /opt/homebrew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
          fi
        ''}
        #历史纪录条目数量
        export HISTSIZE=10000
        #注销后保存的历史纪录条目数量
        export SAVEHIST=10000
        #以附加的方式写入历史纪录
        setopt INC_APPEND_HISTORY
        #如果连续输入的命令相同，历史纪录中只保留一个
        setopt HIST_IGNORE_DUPS
        #为历史纪录中的命令添加时间戳
        #setopt EXTENDED_HISTORY
        #启用 cd 命令的历史纪录，cd -[TAB]进入历史路径
        setopt AUTO_PUSHD
        #相同的历史路径只保留一个
        setopt PUSHD_IGNORE_DUPS
        #在命令前添加空格，不将此命令添加到纪录文件中
        #setopt HIST_IGNORE_SPACE

        # 不保留重复的历史记录项
        setopt hist_ignore_all_dups
        # 在命令前添加空格，不将此命令添加到记录文件中
        setopt hist_ignore_space
      '';
      history.ignorePatterns = [ "rm *" "pkill *" "ls *" "sysdo search *" ];
    };
    zoxide.enable = true;
    starship = {
      enable = true;
      package = pkgs.starship;
      settings = {
        add_newline = false;
        # format = "$character";
        # right_format = "$all";
      };
    };
  };
}
