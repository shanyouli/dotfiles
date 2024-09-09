{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfm = config.modules;
  cfg = cfm.shell.nushell;
  getBaseName = str: builtins.head (lib.splitString "." (lib.last (lib.splitString "/" str)));
  scriptHomeFunc = l:
    concatMapAttrs (n: v: {"nushell/scripts/${n}.nu".source = v;}) (builtins.listToAttrs (map (vl: {
        name = getBaseName vl;
        value =
          if hasPrefix "/" vl
          then x
          else if hasInfix "/" vl
          then "${config.dotfiles.configDir}/${vl}"
          else "${config.dotfiles.configDir}/${vl}/${vl}.script.nu";
      })
      l));
in {
  options.modules.shell.nushell = {
    enable = mkEnableOption "A more modern shell";
    cacheCmd = with types; mkOpt' (listOf str) [] "cache file";
    cachePrev = mkOpt' types.lines "" "Initialization script at build time";
    rcInit = mkOpt' types.lines "" "Init nushell";
    cmpFiles = with types; mkOpt' (listOf (either str path)) [] "nushell plugins";
    scriptFiles = with types; mkOpt' (listOf (either str path)) [] "nushell scripts";
  };
  config = mkIf cfg.enable {
    user.packages = [pkgs.unstable.nushell];
    modules.app.editor.helix = {
      languages = {
        language = [
          {
            name = "nu";
            language-servers = ["nushell-lsp"];
          }
        ];
        language-server.nushell-lsp.command = "nu";
        language-server.nushell-lsp.args = ["--lsp"];
      };
    };
    modules.app.editor.nvim.lsp = ["nushell"];
    modules.app.editor.vscode.extensions = with pkgs.unstable.vscode-extensions; [
      thenuprojectcontributors.vscode-nushell-lang
    ];
    home.configFile =
      {
        "nushell/cache/extrarc.nu".text = ''
          ${optionalString (cfg.cacheCmd != []) (concatMapStrings (s: let
              x = builtins.baseNameOf (builtins.head (builtins.split " " s));
            in ''
              source ${config.home.cacheDir}/nushell/${x}.nu
            '')
            cfg.cacheCmd)}
          ${concatStringsSep "\n" (map (x: "use ${x} *") cfg.cmpFiles)}
          ${concatStringsSep "\n" (mapAttrsToList (n: v: ''alias ${n} = ${v}'')
              (filterAttrs (n: v: v != "" && n != "rm" && n != "rmi") config.modules.shell.aliases))}
          ${cfg.rcInit}
          alias nure = exec nu
          ${concatMapStringsSep "\n" (x: "use ${getBaseName x}.nu *") cfg.scriptFiles}
        '';
      }
      // (scriptHomeFunc cfg.scriptFiles);
  };
}
