# When I'm stuck in the terminal or don't have access to Emacs, (neo)vim is my
# go-to. I am a vimmer at heart, after all.

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors.vim;
in {
  options.modules.editors.vim = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      editorconfig-core-c
      nodejs
      (neovim.override {
        viAlias = true;
        vimAlias = true;
        configure = {
          packages.myPlugins = with pkgs.vimPlugins; {
            start = [
              # UI
              gruvbox-community # theme
              lightline-vim         # modeline
              vim-startify      # startup Buffer
              lightline-bufferline # bufferline lightline
              vim-bufferline           # bufferline
              vim-nix           # nix Language
              vim-clap
              coc-nvim
              coc-fzf
              fzf
              fzf-vim
            ];
            opt = [ vim-plug ];
          };
          plug.plugins = with pkgs.vimPlugins; [ vim-nix ];
          customRC = ''
            source ${pkgs.vimPlugins.vim-plug}/share/vim-plugins/vim-plug/plug.vim
            set background=${config.modules.theme.active}
            colorscheme gruvbox

            " modeline
            set laststatus=2
            " bufferline
            set showtabline=2
            let g:bufferline_echo=0
            let g:bufferline_modified='[+]'
            set noshowmode
            if filereadable(expand("${xdgConfig}/nvim/init.vim"))
              source ${xdgConfig}/nvim/init.vim
            endif
          '';
        };
      })
    ];

    # This is for non-neovim, so it loads my nvim config
    # env.VIMINIT = "let \\$MYVIMRC='\\$XDG_CONFIG_HOME/nvim/init.vim' | source \\$MYVIMRC";

    environment.shellAliases.v =  "nvim";

    home.configFile."nvim" = { source = "${configDir}/vim"; recursive = true; };
  };
}
