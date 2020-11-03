{ config, options, pkgs, lib, ... }:
with lib;
let cfg = config.modules.shell.tmux ;
    # The developer of tmux chooses not to add XDG support for religious
    # reasons (see tmux/tmux#142). Fortunately, nix makes this easy:
    tmux = (pkgs.writeScriptBin "tmux" ''
         #!${pkgs.stdenv.shell}
         exec ${pkgs.tmux}/bin/tmux -f "$TMUX_HOME/config" "$@"
         '');
in {
  options.modules.shell.tmux = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    my = {
      packages = [ tmux ];

      env.TMUX_HOME = "$XDG_CONFIG_HOME/tmux";
      env.TMUXIFIER = "$XDG_DATA_HOME/tmuxifier";
      env.TMUXIFIER_LAYOUT_PATH = "$XDG_DATA_HOME/tmuxifier";
      env.PATH = [ "$XDG_DATA_HOME/tmuxifier/bin" ];

      zsh.rc = ''
        [[ -d $TMUXIFIER ]] || git clone --depth 1 https://github.com/jimeh/tmuxifier $TMUXIFIER
        _cache tmuxifier init -
        ${lib.readFile <config/tmux/aliases.zsh>}
      '';
      home.xdg.configFile = {
        "tmux" = { source = <config/tmux>; recursive = true; };
        "tmux/plugins".text = ''
          run-shell ${pkgs.tmuxPlugins.copycat}/share/tmux-plugins/copycat/copycat.tmux
          run-shell ${pkgs.tmuxPlugins.prefix-highlight}/share/tmux-plugins/prefix-highlight/prefix_highlight.tmux
          run-shell ${pkgs.tmuxPlugins.yank}/share/tmux-plugins/yank/yank.tmux
        '';
      };
    };
  };
}
