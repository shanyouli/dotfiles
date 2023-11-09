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
    # BUG: (wrong-number-of-arguments (3 . 4) 2)
    # @see https://github.com/hlissner/doom-emacs/issues/4534
    # BUMP: emacsPgtkGcc version
    emacsPgtkGcc.overlay = final: prev: {
      emacsPgtkGcc =  prev.emacsPgtkGcc.overrideAttrs (oldAttrs: rec {
        version = "20210203.0";
        src = prev.fetchFromGitHub {
          owner = oldAttrs.pname;
          repo = oldAttrs.pname;
          rev = "b6a0af3e117c2eed3e70e2545549a7531834e758";
          sha256 = "0ivrnrml649jnsw72dapwik5fin4yxg8gfcy2r7p51m4g21fpbdf";
        };
      });
    };
in {
  options.modules.editors.emacs = {
    enable = mkBoolOpt false;
    gccEnable = mkBoolOpt true;
    pluginEnable = mkBoolOpt true;
    rimeEnable = mkBoolOpt true;
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
      nixpkgs.overlays = [ inputs.emacs-overlay.overlay emacsPgtkGcc.overlay ];
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
        extraPkgs = epkgs: with epkgs; [
          vterm gif-screencast vlf emacs-webkit
        ];
        doom.pkg.prefer = [
          "vterm" "gif-screencast" "vlf"
        ];
      };
      user.packages = with pkgs;[ scrot imagemagick gifsicle ];
    })
    (mkIf cfg.rimeEnable {
      modules.editors.emacs = {
        extraPkgs = epkgs: with epkgs; [
          rime
          dash
          posframe
        ];
        doom.pkg.prefer = [ "rime" "dash" "posframe" ];
        doom.pkg.disable = [ "sis" ];
        doom.confInit = ''
          (setq rime-user-data-dir "${xdgCache}/emacs/rime/")
          (setq rime-emacs-module-header-root "${cfg.package}/include")
          (setq rime-librime-root "${pkgs.librime}")
          (setq rime-share-data-dir "${pkgs.brise}/share/rime-data")
          (defadvice! my/pgtk-im-con (&rest _)
             "Set Chinese fonts."
             :after #'doom-init-extra-fonts-h
             (when (eq window-system 'pgtk)
               (pgtk-use-im-context nil)))
          (global-set-key [f13] 'toggle-input-method)
          (global-set-key (kbd "<269025153>") 'toggle-input-method)
        '';
      };
      home.file =
        let fileDir = "${configDir}/rime";
            defDir = ".cache/emacs/rime";
            defCustom = "${defDir}/default.custom.yaml";
            cloverCustom = "${defDir}/clover.custom.yaml";
        in {
          "${defCustom}".source = "${fileDir}/default.custom.yaml";
          "${cloverCustom}".source = "${fileDir}/clover.custom.yaml";
        };
      home.onReload.emacsRimeEnable = ''
        _emacsRimeSync=${xdgCache}/emacs/rime/installation.yaml
        if [[ -f $_emacsRimeSync  ]]; then
          grep "sync_dir:" $_emacsRimeSync >/dev/null || {
            ${pkgs.gnused}/bin/sed -i "/installation_id.*/c \
              installation_id: \"emacs-rime\"\
              \nsync_dir: \"${homeDir}\/Dropbox\/rime\"" $_emacsRimeSync
          }
        else
          mkdir -p $(dirname $_emacsRimeSync)
          echo -e "installation_id: \"emacc-rime\"\
            \nsync_dir: \"${homeDir}/Dropbox/rime\"" > $_emacsRimeSync
        fi
        unset _emacsRimeSync
      '';
    })
    (mkIf config.services.xserver.enable {
      user.packages = [
        (pkgs.makeDesktopItem {
          name = "emacsclient";
          desktopName = "Emacs Client";
          icon = "emacs";
          exec = "${binDir}/myemacs desktop %u";
          genericName = "Text Editor";
          mimeType = concatStringsSep ";" [
            "text/english"
            "text/plain"
            "text/x-makefile"
            "text/x-c++hdr"
            "text/x-c++src"
            "text/x-chdr"
            "text/x-csrc"
            "text/x-java"
            "text/x-moc"
            "text/x-pascal"
            "text/x-tcl"
            "text/x-tex"
            "application/x-shellscript"
            "text/x-c"
            "text/x-c++"
            "x-scheme-handler/org-protocol"
          ];
          comment = "Edit text";
          terminal = "false";
          categories = "Development;TextEditor";
        })
      ];
      services.xserver.displayManager.sessionCommands = "${binDir}/myemacs daemon";
      home.defaultApps."x-scheme-handler/org-protocol" = "emacsclient.desktop";
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
          (defvar using-nix-config-p t "Using Nixos config")
          ${lib.optionalString cfg.rimeEnable ''
            (defvar using-emacs-rime-p t "Using Emacs-Rime Input Method.")
          ''}
        '';
        "doom/config.init.el".text = let
          f = {
            mono = "JetBrains Mono";
            monoSize = "11";
            emoji = "JoyPixels";
            cjk = "WenQuanYi Micro Hei Mono";
          };
          theme = "doom-gruvbox" + (if (config.modules.theme.active == "light")
                                    then "-light"
                                    else "");
        in ''
          (setq doom-font (font-spec :family "${f.mono}" :size ${f.monoSize}))
          (defadvice! my/use-chinese-font-a (&rest _)
             "Set Chinese fonts."
             :after #'doom-init-extra-fonts-h
             (dolist (charset '(kana han cjk-misc bopomofo))
               (set-fontset-font t charset "${f.cjk}"))
             ;;(set-fontset-font t '(#x4e00 . #x9fff) "${f.cjk}")
             (set-fontset-font t 'symbol "${f.emoji}"))
          (setq doom-theme '${theme})
          ${cfg.doom.confInit}
        '';
        "doom/packages.init.el".text = let
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
