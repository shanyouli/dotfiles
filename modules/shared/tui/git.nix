{
  config,
  lib,
  pkgs,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.git;
in
{
  options.modules.git = with types; {
    enable = mkBoolOpt false;
    enGui = mkBoolOpt config.modules.gui.enable;
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      github-cli
      git-crypt
      # pre-commit # git 提交前自检, 使用 pipx安装
      (mkIf (cfg.enGui && stdenvNoCC.isLinux) github-desktop)
      # 更快的克隆速度。
      gitoxide
    ];
    home.programs.git = {
      enable = true;
      settings = {
        aliases = {
          fix = "commit --amend --no-edit";
          oops = "reset HEAD~1";
          sub = "submodule update --init --recursive";
          ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
        };
        user.name = mkDefault my.fullName;
        user.email = mkDefault my.useremail;
        credential.helper =
          if pkgs.stdenvNoCC.isDarwin then "osxkeychain" else "cache --timeout=1000000000";
        commit.verbose = true;
        fetch.prune = true;
        http.sslVerify = true;
        init.defaultBranch = "main";
        pull.rebase = true;
        push.followTags = true;
        core.quotePath = false;
      };
      package = pkgs.git;
      signing = {
        key = mkDefault my.useremail;
        signByDefault = true;
      };
      lfs.enable = true;
    };
    home.programs.delta = {
      enable = true;
      options = {
        side-by-side = true;
        line-numbers = true;
      };
    };
  };
}
