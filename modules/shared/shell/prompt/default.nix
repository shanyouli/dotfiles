{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.shell;
  cfg = cfp.prompt;
  support_tools = [
    "starship"
    "oh-my-posh"
  ];
in
{
  options.modules.shell.prompt = {
    bash.enable = mkBoolOpt true;
    zsh.enable = mkEnableOption "whether to use powerlevel10k config";
    fish.enable = mkEnableOption "Whether to use tide prompt";
    default = mkOption {
      type = types.str;
      default = "";
      apply = str: if builtins.elem str support_tools then str else "";
    };
  };
  config = mkMerge [
    (mkIf (cfg.default == "starship") { modules.shell.prompt.starship.enable = true; })
    (mkIf (cfg.default == "oh-my-posh") { modules.shell.prompt.oh-my-posh.enable = true; })
  ];
}
