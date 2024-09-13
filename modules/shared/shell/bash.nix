{
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfp = config.modules.shell;
  cfg = cfp.bash;
in {
  options.modules.shell.bash = {
    enable = mkEnableOption "Whether to use bash";
    envInit = mkOpt' types.lines "" "~/.profile files";
    prevInit = mkOpt' types.lines "" "~/.bashrc prefix init";
    rcInit = mkOpt' types.lines "" "~/.bashrc rc init";
  };
  config = mkIf cfg.enable {
    home.programs.bash = {
      enable = true;
      historySize = 100000;
      historyFile = ''''${XDG_CACHE_HOME:-~/.cache}/bash_history'';
      historyFileSize = 1000000;
      historyControl = ["ignorespace" "ignoredups" "erasedups"];
      historyIgnore = ["ls" "cd" "z" "exit"];
      sessionVariables = filterAttrs (n: v: n != "PATH") cfp.env;
      shellAliases = mkAliasDefinitions options.modules.shell.aliases;
      profileExtra = mkAliasDefinitions options.modules.shell.bash.envInit;
      bashrcExtra = mkAliasDefinitions options.modules.shell.bash.prevInit;
      initExtra = mkAliasDefinitions options.modules.shell.bash.rcInit;
    };
    modules.shell.bash.envInit = mkOrder 10 (lib.optionalString (builtins.hasAttr "PATH" cfp.env) ''
      export PATH=${concatStringsSep ":" cfp.env.PATH}''${PATH:+:}''${PATH}
    '');
    modules.shell.bash.rcInit = mkOrder 5000 ''
      alias vish="''${EDITOR:-vim} ~/.bashrc_local"
      [[ -f ~/.bashrc_local ]] && source ~/.bashrc_local
    '';
  };
}
