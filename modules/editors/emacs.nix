# Emacs is my main driver. I'm the author of Doom Emacs
# https://github.com/hlissner/doom-emacs. This module sets it up to meet my
# particular Doomy needs.

{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors.emacs;
    emacsPackages = let epkgs = pkgs.emacsPackagesFor cfg.package;
                    in epkgs.overrideScope' cfg.overrides;
    emacsWithPackages = emacsPackages.emacsWithPackages;

    selectorFunction = mkOptionType {
      name = "selectorFunction";
      description = "Function that takes an attribute set and returns a list"
                    + " containing a selection of the values of the input set";
      check = isFunction;
      merge = _loc: defs: as: concatMap (select: select as) (getValues defs);
    };
    overlayFunction = mkOptionType {
      name = "overlayFunction";
      description = "An overlay function, takes self and super and returns"
                    + " an attribute set overriding the desired attributes.";
      check = isFunction;
      merge = _loc: defs: self: super:
        foldl' (res: def: mergeAttrs res (def.value self super)) { } defs;
    };

in {
  options.modules.editors.emacs = {
    enable = mkBoolOpt false;
    gccEnable = mkBoolOpt true;
    pluginEnable = mkBoolOpt true;
    rimeEnable = mkBoolOpt true;
    serviceEnable = mkBoolOpt false;
    doom = {
      enable  = mkBoolOpt true;
      fromSSH = mkBoolOpt false;
      pkg = {
        prefer = mkOption {
          type = with types; listOf str;
          default = [];
          description = "TODO";
        };
        disable = mkOption {
          type = with types; listOf str;
          default = [];
          description = "TODO";
        };
      };
      confInit = mkOpt' types.lines "" ''
        Conf Lines to be written to $XDG_CONFIG_HOME/doom/config.init.el and
        loaded by $XDG_CONFIG_HOME/doom/config.el
      '';
    };
    extraPkgs = mkOption {
      default = self: [];
      type = selectorFunction;
      defaultText = "epkgs: []";
      example = literalExample "epkgs: [epkgs.emms epkgs.magit ]";
      description = ''
        Extra packages available to Emacs. To get a list of
        available packages run:
        <command>nix-env -f '&lt;nixpkgs&gt;' -qaP -A emacsPackages</command>.
      '';
    };
    overrides = mkOption {
      default = self: super: { };
      type = overlayFunction;
      defaultText = "self: super: {}";
      example = literalExample ''
        self: super: rec {
          haskell-mode = self.melpaPackages.haskell-mode;
          # ...
        };
      '';
      description = ''
        Allows overriding packages within the Emacs package set.
      '';
    };
    package = mkOption {
      type = types.package;
      defaultText = literalExample "pkgs.emacs";
      example = literalExample "pkgs.emacs26-nox";
      description = "The Emacs Package to use.";
    };
    pkg = mkPkgReadOpt "The emacs include overrides and plugins";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];
      modules.editors.emacs.doom.confInit = ''
        (setq mydotfile "/etc/nixos")
      '';
      modules.editors.emacs.package =  #pkgs.emacsPgtkGcc;
        let ebPkg = if cfg.gccEnable then pkgs.emacsPgtkGcc else pkgs.emacs ;
        in (if cfg.rimeEnable then ebPkg.overrideAttrs(attrs: {
          postInstall = (attrs.postInstall or "") + ''
            rm -rf $out/share/applications/emacsclient.desktop
            sed -i "/^Exec=emacs %F$/c \
              Exec=env GTK_IM_MODULE= QT_IM_MODULE= XMODIFIERS=; emacs %F" \
              $out/share/applications/emacs.desktop
          '';
        }) else ebPkg);
      user.packages = with pkgs; [
        ## Doom dependencies
        git
        (ripgrep.override {withPCRE2 = true;})
        gnutls              # for TLS connectivity

        ## Optional dependencies
        fd                  # faster projectile indexing
        imagemagick         # for image-dired
        (mkIf (config.programs.gnupg.agent.enable)
          pinentry_emacs)   # in-emacs gnupg prompts
        zstd                # for undo-fu-session/undo-tree compression

        ## Module dependencies
        # :checkers spell
        (aspellWithDicts (ds: with ds; [
          en en-computers en-science
        ]))
        # :checkers grammar
        languagetool
        # :tools editorconfig
        editorconfig-core-c # per-project style config
        # :tools lookup & :lang org +roam
        sqlite
        # :lang cc
        ccls
        # :lang javascript
        nodePackages.javascript-typescript-langserver
        # :lang latex & :lang org (latex previews)
        texlive.combined.scheme-medium
        # :lang rust
        rustfmt
        unstable.rust-analyzer
      ];
      fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];
    }
    (mkIf cfg.gccEnable {
      user.packages = [ pkgs.binutils ];
    })
    (mkIf cfg.pluginEnable {
      modules.editors.emacs = {
        extraPkgs = epkgs: with epkgs; [ vterm gif-screencast vlf ];
        doom.pkg.prefer = [ "vterm" "gif-screencast" "vlf" ];
      };
      user.packages = with pkgs;[ scrot imagemagick gifsicle ];
    })
    (mkIf cfg.rimeEnable {
      modules.editors.emacs = {
        extraPkgs = epkgs: with epkgs; [
          (rime.overrideAttrs (esuper: {
            buildInputs = esuper.buildInputs ++ [ pkgs.librime pkgs.brise ];
            postInstall = ''
              pushd source
              LIBRIME_ROOT="${pkgs.librime}/"
              MODULE_FILE_SUFFIX=".so"
              make lib
              install -m444 -t $out/share/emacs/site-lisp/elpa/rime-** ./*.so
              rm -r $out/share/emacs/site-lisp/elpa/rime-*/{lib.c,Makefile}
              popd
            '';
          }))
          dash
          posframe
        ];
        doom.pkg.prefer = [ "rime" "dash" "posframe" ];
        doom.confInit = ''
          (setq rime-emacs-module-header-root "${cfg.package}/include")
          (setq rime-librime-root "${pkgs.librime}")
          (setq rime-share-data-dir "${pkgs.brise}/share/rime-data")
          (defadvice! my/pgtk-im-con (&rest _)
             "Set Chinese fonts."
             :after #'doom-init-extra-fonts-h
             (when (eq window-system 'pgtk)
               (pgtk-use-im-context nil)))
        '';
      };
      user.packages = (mkIf config.services.xserver.enable [
        (pkgs.makeDesktopItem {
          name = "emacsclient";
          desktopName = "Emacs Client";
          icon = "emacs";
          exec = "${binDir}/emacs/eclient %F";
          genericName = "Text Editor";
          mimeType = "text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++";
          comment = "Edit text";
          terminal = "false";
          categories = "Development;TextEditor";
          extraEntries = "StartupWMClass=EmacsD";
        })
      ]);
      services.xserver.displayManager.sessionCommands = "${binDir}/emacs/edaemon";
    })
    {
      modules.editors.emacs.doom.pkg.disable = [
        (mkIf (! config.modules.shell.sdcv.enable) "sdcv")
        (mkIf (! cfg.rimeEnable) "rime")
      ];
      modules.editors.emacs.pkg = emacsWithPackages cfg.extraPkgs;
      user.packages = [ cfg.pkg ];
      env.PATH = [ "$XDG_CONFIG_HOME/emacs/bin" ];
      modules.shell.zsh.rcFiles = [ "${configDir}/emacs/aliases.zsh" ];
      # init.doomEmacs = mkIf cfg.doom.enable ''
      #   if [ -d $HOME/.config/emacs ]; then
      #      ${optionalString cfg.doom.fromSSH ''
      #         git clone git@github.com:hlissner/doom-emacs.git $HOME/.config/emacs
      #         git clone git@github.com:hlissner/doom-emacs-private.git $HOME/.config/doom
      #      ''}
      #      ${optionalString (cfg.doom.fromSSH == false) ''
      #         git clone https://github.com/hlissner/doom-emacs $HOME/.config/emacs
      #         git clone https://github.com/hlissner/doom-emacs-private $HOME/.config/doom
      #      ''}
      #   fi
      # '';
      home.configFile =  {
        "doom/config.org".source = "${configDir}/emacs/config.org";
        "doom/init.el".text =
          let  basefile = "${configDir}/emacs/init.el";
          in ''
          ${readFile basefile}
          (setq using-nix-config-p t)
        '';
        "doom/config.init.el".text =
          let f = {
                mono = "mononoki";
                monoSize = "12";
                emoji = "Noto Color Emoji";
                cjk = "Sarasa Mono SC";
              };
          in ''
          (setq doom-font (font-spec :family "${f.mono}" :size ${f.monoSize}))
          (defadvice! my/use-chinese-font-a (&rest _)
             "Set Chinese fonts."
             :after #'doom-init-extra-fonts-h
             (dolist (charset '(kana han cjk-misc bopomofo))
               (set-fontset-font t charset "${f.cjk}"))
             ;;(set-fontset-font t '(#x4e00 . #x9fff) "${f.cjk}")
             (set-fontset-font t 'symbol "${f.emoji}"))
         ${cfg.doom.confInit}
      '';
        "doom/packages.init.el".text =
          let
            prefer = map (str: "(package! ${str} :built-in 'prefer)") cfg.doom.pkg.prefer;
            disable = map (str: "(disable-packages! ${str})") cfg.doom.pkg.disable;
          in ''
            ;;; disable some package.
            ${concatStringsSep "\n" disable}

            ;;; Prefer buildin package.
            ${concatStringsSep "\n" prefer}
      '';
      };
    }
  ]);
}
