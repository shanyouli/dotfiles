{
  lib,
  config,
  pkgs,
  my,
  ...
}:
with lib;
with my;
let
  cfm = config.modules;
  cfg = cfm.shell.nix-index;
  cfgpkg = pkgs.nix-index;
in
{
  options.modules.shell.nix-index = {
    enable = mkEnableOption "Whether to nix-index";
  };
  config = mkIf cfg.enable {
    home.programs.nix-index = {
      enable = true;
      package = cfgpkg;
      enableBashIntegration = true;
      # package = inputs.nurpkgs.currentSystem.packages.nix-index;
    };
    modules.shell = {
      zsh.rcInit = ''
        _source ${cfgpkg}/etc/profile.d/command-not-found.sh
      '';
      # see @https://github.com/nix-community/nix-index/issues/126#issuecomment-771210054
      # see @https://github.com/viperML/dotfiles/raw/bbdfed65a743dac2ae0ac0271f47bce7d8bb83c2/packages/nix-index/command-not-found.fish
      fish.rcInit = ''
        function __fish_default_command_not_found_handler --on-event fish_command_not_found \
            --description "default command not found handler"
            set cmd $argv[1]
            set attrs (
              ${cfgpkg}/bin/nix-locate --minimal --no-group --type x --type s --whole-name --at-root "/bin/$cmd" \
                | string replace ".out" ""
            )
            set len (count $attrs)
            switch $len
                case 0
                    if type -q brew && test (count $cmd) -gt 0
                        echo -e >&2 "\e[31m-> $cmd: command not found\e[39m\n"
                        echo (brew which-formula --explain $cmd) >&2
                    else
                        echo "$cmd"': command not found' >&2
                    end
                case 1
                    if set -q NIX_AUTO_RUN
                        set result (nix build --no-link --print-out-paths nixpkgs\#$attrs)
                        $result/bin/$argv
                        return 127
                    else
                        echo -e >&2 "\e[31m-> $cmd: command not found\e[39m\n"
                        for item in $attrs
                            echo "nix shell nixpkgs#$item"
                        end
                    end
                case '*'
                    echo -e >&2 "\n\e[31m-> $cmd: command not found\e[39m\n"
                    for item in $attrs
                        echo "nix shell nixpkgs#$item"
                    end
            end
        end
      '';
      nushell.rcInit = ''
        $env.config = ($env | default {} config).config
        $env.config.hooks = ($env.config | default {} hooks).hooks
        $env.config.hooks.command_not_found = {|cmd_name|
            try {
                let attrs = (${cfgpkg}/bin/nix-locate --minimal --no-group --type x --type s --whole-name --at-root $"/bin/($cmd_name)" | lines)
                if ($attrs | is-empty) {
                    if (which brew | is-empty) {
                        return null
                    } else {
                        return (brew which-formula --explain $cmd_name)
                    }
                } else {
                    let out = $attrs | each { |x| $x | str replace ".out" "" | $"        nix-shell -p ($in)" } | str join "\n"
                    return $"\nThe program ($cmd_name) is not installed, but available from the following location\(s\):\n($out)"
                }
            }
        }
      '';
    };
  };
}
