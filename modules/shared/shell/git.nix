{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.shell.git;
in {
  options.modules.shell.git = with types; {
    enable = mkBoolOpt false;
    enGui = mkBoolOpt config.modules.opt.enGui;
  };
  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      github-cli
      git-crypt
      # pre-commit # git 提交前自检, 使用 pipx安装
      (mkIf (cfg.enGui && stdenvNoCC.isLinux) github-desktop)
      # 更快的克隆速度。
      gitoxide
    ];
    home.programs.git = {
      enable = true;
      package = pkgs.git;
      userName = config.modules.opt.name;
      userEmail = config.modules.opt.email;
      signing = {
        key = "${config.modules.opt.email}";
        signByDefault = true;
      };
      extraConfig = {
        credential.helper =
          if pkgs.stdenvNoCC.isDarwin
          then "osxkeychain"
          else "cache --timeout=1000000000";
        commit.verbose = true;
        fetch.prune = true;
        http.sslVerify = true;
        init.defaultBranch = "main";
        pull.rebase = true;
        push.followTags = true;
        core.quotePath = false;
      };
      aliases = {
        fix = "commit --amend --no-edit";
        oops = "reset HEAD~1";
        sub = "submodule update --init --recursive";
        ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
      };
      delta = {
        enable = true;
        options = {
          side-by-side = true;
          line-numbers = true;
        };
      };
      lfs.enable = true;
    };
  };
}
