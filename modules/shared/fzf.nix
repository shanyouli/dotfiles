{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.modules.fzf;
in {
  options.modules.fzf = {
    enable = mkBoolOpt false;
    # 默认使用 exa -T 取代 tree
    treeEnable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (let
    pkg = pkgs.fzf;
    fd = "${pkgs.fd}/bin/fd";
    bat = "${pkgs.bat}/bin/bat";
    # 使用 exa 取代 tree, tree -C
    tree = "${pkgs.eza}/bin/eza -T";
  in {
    my = {
      user.packages = [pkg pkgs.my-nix-scripts];
    };
    modules.zsh = {
      prevInit = ''
        FZF_DEFAULT_COMMAND="${fd} -H -I --type f"
        FZF_DEFAULT_OPTIONS="${fd} --height 50%"
        FZF_CTRL_T_COMMAND="${fd} -H -I --type f"
        FZF_CTRL_T_OPTS="--preview '${bat} --color=always --plain --line-range=:200 {}'"
        FZF_ALT_C_COMMAND="${fd} -H -I --type d -E '.git*'"
        FZF_ALT_C_OPTS="--preview '${tree} -L 2 {} | head -2000'"
        # FZF_CTRL_R_OPTS=""
        source ${pkg}/share/fzf/completion.zsh
        source ${pkg}/share/fzf/key-bindings.zsh
      '';
      rcFiles = ["${configDir}/fzf/fzf.zsh"];
    };
  });
}
