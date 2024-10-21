{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
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
          then "${my.dotfiles.config}/${vl}"
          else "${my.dotfiles.config}/${vl}/${vl}.script.nu";
      })
      l));
in {
  options.modules.shell.nushell = {
    enable = mkEnableOption "A more modern shell";
    cacheCmd = with types; mkOpt' (listOf str) [] "cache file";
    rcInit = mkOpt' types.lines "" "Init nushell";
    cmpFiles = with types; mkOpt' (listOf (either str path)) [] "nushell plugins";
    scriptFiles = with types; mkOpt' (listOf (either str path)) [] "nushell scripts";
    package = mkPackageOption pkgs.unstable "nushell" {};
  };
  config = mkIf cfg.enable {
    home = {
      packages = [cfg.package pkgs.unstable.bash-env-json];
      configFile =
        {
          "nushell/sources/config".text = ''
            ${concatMapStrings (s: let
                x = builtins.baseNameOf (builtins.head (builtins.split " " s));
              in ''
                source (($SOURCE_PATH | path join "${x}") | path expand)
              '')
              cfg.cacheCmd}
            ${concatStringsSep "\n" (map (x: "use ${x} *") cfg.cmpFiles)}
            ${concatStringsSep "\n" (mapAttrsToList (n: v: ''alias ${n} = ${v}'')
                (filterAttrs (n: v: v != "" && n != "rm" && n != "rmi") config.modules.shell.aliases))}
            ${cfg.rcInit}
            alias nure = exec nu
            ${concatMapStringsSep "\n" (x: "use ${getBaseName x}.nu *") cfg.scriptFiles}
          '';
        }
        // (scriptHomeFunc cfg.scriptFiles);
      initExtra = let
        appnameFn = s: lib.head (lib.splitString " " s);
      in ''
        let nu_sources = "${config.home.configDir}" | path join "nushell" "sources"
        if (not ($nu_sources | path exists)) {
          ^mkdir -p $nu_sources -m 755
        }
        ${concatMapStrings (s: ''
            ${s} | save -f ($nu_sources | path join ("${appnameFn s}" | path basename))
          '')
          cfg.cacheCmd}
      '';
    };
    modules.app.editor = {
      helix = {
        languages = {
          language = [
            {
              name = "nu";
              language-servers = ["nushell-lsp"];
            }
          ];

          language-server = {
            nushell-lsp.command = "nu";
            nushell-lsp.args = ["--lsp"];
          };
        };
      };
      nvim.lsp = ["nushell"];
      vscode.extensions = with pkgs.unstable.vscode-extensions; [
        thenuprojectcontributors.vscode-nushell-lang
      ];
    };
  };
}
