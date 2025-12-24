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
  env-paths = pkgs.runCommandLocal "env-paths" { } (
    let
      profilePath = makeBinPath (
        builtins.filter (x: x != "/nix/var/nix/profiles/default") config.environment.profiles
      );
      printOuts = optionalString config.modules.macos.brew.enable ''
        if [[ -x ${config.homebrew.brewPrefix}/brew ]]; then
          eval "$(${config.homebrew.brewPrefix}/brew shellenv bash)"
        fi
      '';
    in
    ''
      PATH=""
      if [ -x /usr/libexec/path_helper ]; then
        eval $(/usr/libexec/path_helper -s)
      else
        PATH=/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin
      fi
      ${printOuts}
      echo "__BASE_NIX_DARWIN_PATH=\"$PATH\";" > $out
      echo '__BASE_NIX_DARWIN_PATH="${profilePath}''${__BASE_NIX_DARWIN_PATH:+:}$__BASE_NIX_DARWIN_PATH";' >> $out
      echo "export __BASE_NIX_DARWIN_PATH;" >> $out
    ''
  );
  fix_path = writeNuScript' {
    name = "fix_PATH";
    text = ''
      def main [s1: string, s2: string ]: nothing -> string {
        let base = $s2 | split row (char esep) | uniq
        let newlist = $s1 | split row (char esep)
                          | uniq
                          | where {|x| ($x not-in $base) }
                          | where {|x| ($x not-in [" " ":" "/nix/var/nix/profiles/default/bin"]) }
        if ($newlist | is-empty) {
          $base | str join (char esep)
        } else {
          [
            ...$newlist
            ...$base
          ] | str join (char esep)
        }
      }
    '';
    nushell =
      if config.modules.shell.nushell.enable then config.modules.shell.nushell.package else pkgs.nushell;
  };
in
{
  config = {
    environment = mkMerge [
      {
        # NOTE: use $HOME replace ${config.home.stateDir}
        profiles =
          let
            fn =
              s:
              let
                lastsuffix = removePrefix my.homedir s;
                prefix = if s == lastsuffix then s else "$HOME${lastsuffix}";
              in
              "${prefix}/nix/profile";
          in
          mkOrder 800 [ (fn config.home.stateDir) ];

        extraInit = mkMerge [
          (
            let
              envPathString = if config.env ? "PATH" then config.env.PATH else null;
            in
            mkOrder 350 ''
              [ -z "$__BASE_NIX_DARWIN_PATH" ] && {
                . ${env-paths}
                __new_path="$(${fix_path} "$PATH" "$__BASE_NIX_DARWIN_PATH")"
                export PATH="$__new_path"
                unset __new_path
              }
              ${optionalString (envPathString != null) ''export PATH="${envPathString}:$PATH"''}
            ''
          )
          (mkIf config.modules.macos.brew.enable (
            let
              prefix = removeSuffix "/bin" config.homebrew.brewPrefix;
            in
            ''
              export HOMEBREW_PREFIX=${prefix}
              export HOMEBREW_CELLAR=${prefix}/Cellar
              export HOMEBREW_REPOSITORY=${prefix}
              [ -z "''${MANPATH-}" ] || export MANPATH=":''${MANPATH#:}";
              export INFOPATH="/opt/homebrew/share/info:''${INFOPATH:-}";
            ''
          ))
        ];
      }
      (mkIf config.modules.shell.fish.enable {
        etc."fish/nixos-env-preinit.fish".text = mkMerge [
          (lib.mkBefore ''
            set -g __nixos_path_original $PATH
            test "$IN_NIX_SHELL" = "pure" && return
          '')
          (lib.mkAfter ''
            function __nixos_path_fix -d "fix PATH value"
              set -l result (string replace '$HOME' "$HOME" $__nixos_path_original)
              for elt in $PATH
                if not contains -- $elt $result
                  set -a result $elt
                end
              end
              set -g PATH $result
            end
          '')
        ];
      })
    ];
  };
}
