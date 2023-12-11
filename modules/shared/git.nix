{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.git;
in {
  options.modules.git = with types; {
    enable = mkBoolOpt false;
    enGui = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    my.user.packages = with pkgs; [
      github-cli
      git-crypt
      # pre-commit # git 提交前自检, 使用 pipx安装
      (mkIf (cfg.enGui && stdenvNoCC.isLinux) github-desktop)
    ];
    my.programs.git = {
      enable = true;
      userName = config.my.name;
      userEmail = config.my.email;
      signing = {
        key = "${config.my.email}";
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
    modules.zsh = {
      rcFiles = ["${configDir}/git/git.zsh"];
    };
  };
}
