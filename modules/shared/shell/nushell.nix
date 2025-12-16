# nushell 目前还不适合作为一个常用的 shell 使用，原因:
# 1. 补全虽然有第三工具 carapace 使用，但 carapace 仅覆盖了日常使用中的 80% 的命令
#    自定义补全总会调用外部命令，而不是内部函数，导致 a 和 a subcmd 命令可能调用的不是同一个命令
# 2. 如果作为一个 login 的 shell 来使用，它会从 /etc/profile 中继承环境变量，
#    没有自己的系统级配置文件。类似 /etc/nushell/env.nu etc.
# 3. alias 不支持 | 符号
# 4. source 无法动态加载文件，可以通过特殊方法让它加载成功
# 5. nushell 现在会不稳定，配置或脚本存在兼容性问题。
# 6. 一些小习惯，autopair etc.
{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules.shell;
  cfg = cfm.nushell;
  getBaseName = str: builtins.head (lib.splitString "." (lib.last (lib.splitString "/" str)));
  scriptHomeFunc =
    l:
    concatMapAttrs (n: v: { "nushell/scripts/${n}.nu".source = v; }) (
      builtins.listToAttrs (
        map (vl: {
          name = getBaseName vl;
          value =
            if hasPrefix "/" vl then
              x
            else if hasInfix "/" vl then
              "${my.dotfiles.config}/${vl}"
            else
              "${my.dotfiles.config}/${vl}/${vl}.script.nu";
        }) l
      )
    );
  useCmpFn = cfm.fish.enable || (cfg.cmpFn != "") || (cfg.cmpTable != { });
in
{
  options.modules.shell.nushell = {
    enable = mkEnableOption "A more modern shell";
    cacheCmd = with types; mkOpt' (listOf str) [ ] "cache file";
    rcInit = mkOpt' types.lines "" "Init nushell";
    cmpFiles = with types; mkOpt' (listOf (either str path)) [ ] "nushell plugins";
    cmpFn = mkOpt' types.lines "" "补全函数";
    cmpTable = with types; mkOpt' (attrsOf str) { } "补全列表";
    scriptFiles = with types; mkOpt' (listOf (either str path)) [ ] "nushell scripts";
    package = mkPackageOption pkgs.unstable "nushell" { };
  };
  config = mkIf cfg.enable {
    home = {
      packages = [
        cfg.package
        pkgs.unstable.bash-env-json
      ];
      configFile = mkMerge [
        (mkIf useCmpFn {
          # 暂停使用补全，使用默认补全
          # see@https://www.nushell.sh/cookbook/external_completers.html#putting-it-all-together
          "nushell/autoload/completer.nu".text = ''
             # -*- mode: nushell; -*-
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
             let external_completer = {|spans|
               let expanded_alias = scope aliases
               | where name == $spans.0
               | get -o 0.expansion

               let spans = if $expanded_alias != null {
                 $spans
                 | skip 1
                 | prepend ($expanded_alias | split row ' ' | take 1)
               } else {
                 $spans
               }
               match $spans.0 {
                 ${concatStringsSep "\n" (mapAttrsToList (n: v: "${n} => \$${v}") cfg.cmpTable)}
                 ${optionalString cfm.fish.enable ''
                   # carapace completions are incorrect for nu
                   nu => $fish_completer
                   # fish completes commits and branch names in a nicer way
                   git => $fish_completer
                   # carapace doesn't have completions for asdf
                   asdf => $fish_completer
                   ${optionalString (!cfm.carapace.enable) "_ => $fish_completer"}
                 ''}
                 ${optionalString cfm.carapace.enable "_ => $carapace_completer"}
               } | do $in $spans
             }
            mut current = (($env | default {} config).config | default {} completions)
            $current.completions = ($current.completions | default {} external)
            $current.completions.external = ($current.completions.external
            | default true enable
            | default {$external_completer} completer)

            $env.config = $current
          '';
        })
        {
          "nushell/autoload/zz_config.nu".text = ''
            ${optionalString cfm.carapace.enable (
              let
                carapace_path =
                  if pkgs.stdenvNoCC.isDarwin then
                    ''($env.HOME | path join "Library" "Application Support" "carapace" "bin" | path expand)''
                  else
                    ''($env.XDG_CONFIG_HOME | path join "carapace" "bin" | path expand)'';
              in
              ''
                $env.PATH = ($env.PATH | split row (char esep) | prepend ${carapace_path})
              ''
            )}
            ${concatStringsSep "\n" (map (x: "use ${x} *") cfg.cmpFiles)}
            ${concatStringsSep "\n" (
              mapAttrsToList (n: v: ''alias ${n} = ${v}'') (
                filterAttrs (n: v: v != "" && n != "rm" && n != "rmi") config.modules.shell.aliases
              )
            )}
            ${cfg.rcInit}
            ${concatMapStringsSep "\n" (x: "use ${getBaseName x}.nu *") cfg.scriptFiles}
          '';
        }
        (scriptHomeFunc cfg.scriptFiles)
      ];
    };
    my.user.init.syncNuConfig =
      let
        appnameFn = s: lib.head (lib.splitString " " s);
      in
      ''
        ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${my.dotfiles.config}/nushell/ ${config.home.configDir}/nushell/
        let nu_sources = "${config.home.configDir}" | path join "nushell" "autoload"
        if (not ($nu_sources | path exists)) {
          ^mkdir -p $nu_sources -m 755
        }
        use std/util "path add"
        path add ${makeBinPath [ config.modules.shell.nushell.package ]}
        ${concatMapStrings (s: ''
          ${s} | save -f ($nu_sources | path join (("${appnameFn s}" | path basename) + ".nu"))
        '') cfg.cacheCmd}
      '';
    modules.app.editor = {
      helix = {
        languages = {
          language = [
            {
              name = "nu";
              language-servers = [ "nushell-lsp" ];
            }
          ];

          language-server = {
            nushell-lsp.command = "nu";
            nushell-lsp.args = [ "--lsp" ];
          };
        };
      };
      nvim.lsp = [ "nushell" ];
      vscode.extensions = with pkgs.unstable.vscode-extensions; [
        thenuprojectcontributors.vscode-nushell-lang
      ];
    };
  };
}
