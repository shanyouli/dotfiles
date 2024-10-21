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
  useCmpFn = cfm.fish.enable || (cfg.cmpFn != "") || (cfg.cmpTable != {});
in {
  options.modules.shell.nushell = {
    enable = mkEnableOption "A more modern shell";
    cacheCmd = with types; mkOpt' (listOf str) [] "cache file";
    rcInit = mkOpt' types.lines "" "Init nushell";
    cmpFiles = with types; mkOpt' (listOf (either str path)) [] "nushell plugins";
    cmpFn = mkOpt' types.lines "" "补全函数";
    cmpTable = with types; mkOpt' (attrsOf str) {} "补全列表";
    scriptFiles = with types; mkOpt' (listOf (either str path)) [] "nushell scripts";
    package = mkPackageOption pkgs.unstable "nushell" {};
  };
  config = mkIf cfg.enable {
    home = {
      packages = [cfg.package pkgs.unstable.bash-env-json];
      configFile = mkMerge [
        (mkIf useCmpFn {
          "nushell/sources/completer".text = ''
             ${optionalString cfm.fish.enable ''
              let fish_completer = {|spans|
                ${cfm.fish.package}/bin/fish --command $'complete "--do-complete=($spans | str join " ")"'
                | $"value(char tab)description(char newline)" + $in
                | from tsv --flexible --no-infer
              }
            ''}
             ${optionalString cfm.carapace.enable ''
              let carapace_completer = {|spans: list<string>|
                ${cfm.carapace.package}/bin/carapace $spans.0 nushell ...$spans
                | from json
                | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
              }
            ''}
             ${cfg.cmpFn}
             # The completer will use carace by default
             let external_completer = {
               let expanded_alias = scope aliases
               | where name == $spans.0
               | get -i 0.expansion

               let spans = if $expanded_alias != null {
                 $spans
                 | skip 1
                 | prepend ($expanded-alias | split row ' ' | take 1)
               } else {
                 $spans
               }
               match $spans.0 {
                 ${concatStringsSep "\n" (mapAttrsToList (n: v: "${n} => \$${v}") cfg.cmpTable)}
                 ${optionalString cfg.fish.enable ''
              # carapace completions are incorrect for nu
              nu => $fish_completer
              # fish completes commits and branch names in a nicer way
              git => $fish_completer
              # carapace doesn't have completions for asdf
              asdf => $fish_completer
              ${optionalString (! cfg.carapace.enable) "_ => $fish_completer"}
            ''}
                 ${optionalString cfg.carapace.enable "_ => $carapace_completer"}
               } | do $in $spans
             }
            mut current = (($env | default {} config).config | default {} completions)
            $current.completions = ($current.completions | default {} external)
            $current.completions.external = ($current.completions.external
            | default true enable
            | default $external_completer completer)

            $env.config = $current
          '';
        })
        {
          "nushell/sources/config".text = ''
            ${optionalString cfg.carapace.enable (let
              carapace_path =
                if pkgs.stdenvNoCC.isDarwin
                then ''($env.HOME | path join "Library" "Application Support" "carapace" "bin" | path expand)''
                else ''($env.XDG_CONFIG_HOME | path join "carapace" "bin" | path expand)'';
            in ''
              $env.PATH = ($env.PATH | split row (char esep) | prepend ${carapace_path})
            '')}
            ${concatMapStrings (s: "source ${builtins.baseNameOf (builtins.head (builtins.split " " s))}\n") cfg.cacheCmd}
            ${concatStringsSep "\n" (map (x: "use ${x} *") cfg.cmpFiles)}
            ${concatStringsSep "\n" (mapAttrsToList (n: v: ''alias ${n} = ${v}'')
                (filterAttrs (n: v: v != "" && n != "rm" && n != "rmi") config.modules.shell.aliases))}
            ${cfg.rcInit}
            ${concatMapStringsSep "\n" (x: "use ${getBaseName x}.nu *") cfg.scriptFiles}
          '';
        }
        (scriptHomeFunc cfg.scriptFiles)
      ];
      initExtra = let
        appnameFn = s: lib.head (lib.splitString " " s);
      in ''
        print $"(ansi u)Synchronizing nushell configurations(ansi reset) ..."
        ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${my.dotfiles.config}/nushell/ ${config.home.configDir}/nushell/
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
