{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.my; let
  # emacs 29.0.50 It is not stable
  cfg = config.modules.app.editor.emacs;
  emacsPackages = let
    epkgs = pkgs.emacsPackagesFor cfg.package;
  in
    # epkgs.overrideScope' cfg.overrides;
    epkgs.overrideScope cfg.overrides;
  emacsWithPackages = emacsPackages.emacsWithPackages;
in {
  options.modules.app.editor.emacs = {
    enable = mkBoolOpt false;

    service.enable = mkBoolOpt cfg.enable;
    service.startup = mkBoolOpt true;
    service.keep = mkBoolOpt true;

    rimeEnable = mkBoolOpt true;

    doom = {
      enable = mkBoolOpt true;
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
      default = self: super: {};
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
      # default = inputs.nurpkgs.currentSystem.packages.emacs;
      default = pkgs.unstable.my.emacs;
      defaultText = literalExample "pkgs.emacs";
      example = literalExample "pkgs.emacs26-nox";
      description = "The Emacs Package to use.";
    };
    pkg = mkPkgReadOpt "The emacs include overrides and plugins";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      modules.app.editor.emacs.doom.confInit = ''
        ;; (setq mydotfile "/etc/nixos")
      '';
      modules.app.editor.emacs.extraPkgs = epkgs:
        [
          epkgs.emacsql-sqlite-builtin
          # epkgs.telega
          epkgs.vterm
          epkgs.pdf-tools
          epkgs.saveplace-pdf-view

          epkgs.puni
          epkgs.ef-themes
          epkgs.rainbow-mode
          epkgs.noflet
          # (epkgs.treesit-grammars.with-grammars
          #   (grammars:
          #     with grammars; [
          #       tree-sitter-bash
          #     ]))
          epkgs.treesit-grammars.with-all-grammars
          epkgs.elvish-mode
        ]
        ++ optionals cfg.rimeEnable [
          (epkgs.rime.overrideAttrs (esuper: {
            buildInputs = (esuper.buildInputs or []) ++ [pkgs.librime];
            nativeBuildInputs = [pkgs.gnumake pkgs.gcc];
            preBuild = "";
            postInstall = let
              suffix =
                if pkgs.stdenvNoCC.isDarwin
                then ".dylib"
                else ".so";
            in ''
              export MODULE_FILE_SUFFIX="${suffix}"
              pushd source
              make lib
              install -m444 -t $out/share/emacs/site-lisp/elpa/rime-** librime-emacs''${MODULE_FILE_SUFFIX}
              rm -r $out/share/emacs/site-lisp/elpa/rime-*/{lib.c,Makefile}
              popd
            '';
          }))
        ]
        ++ optionals config.modules.shell.just.enable [epkgs.just-mode epkgs.justl]
        ++ optionals config.modules.shell.nushell.enable [epkgs.nushell-mode];
      modules.app.editor.emacs.pkg = emacsWithPackages cfg.extraPkgs;
    }
    {
      user.packages = [
        cfg.pkg

        pkgs.graphviz
        pkgs.pandoc

        #dirvish 包需要的工具
        # poppler
        pkgs.ffmpegthumbnailer
        pkgs.mediainfo
        # grip markdown 预览配置
        pkgs.python3Packages.grip

        pkgs.emacs-lsp-booster # emacs-lsp-booster , 更快的使用 lsp 服务

        (mkIf (config.programs.gnupg.agent.enable)
          pkgs.pinentry-emacs) # in emacs gnupg prompts
      ];
      modules.shell.python.extraPkgs = ps:
        with ps; [
          epc
          orjson
          six
          paramiko
          rapidfuzz
          sexpdata # 0.0.3, or lsp-bridge
        ];
      modules.shell = {
        env.PATH = ["$XDG_CONFIG_HOME/emacs/bin"];
        env.GRIPHOME = "$XDG_CONFIG_HOME/grip";
        pluginFiles = ["emacs"];
      };
      home.configFile = let
        data-dir =
          if pkgs.stdenvNoCC.isLinux
          then "${pkgs.brise}/share/rime-data"
          else "/Library/Input Methods/Squirrel.app/Contents/SharedSupport";
      in {
        "doom/config.init.el".text = ''
          ${lib.optionalString cfg.rimeEnable ''
            (setq rime-emacs-module-header-root "${cfg.package}/include")
            (setq rime-librime-root "${pkgs.librime}")
            (setq rime-share-data-dir "${data-dir}")
            (setq rime-user-data-dir "${config.home.configDir}/emacs-rime")
          ''}
          (setq lsp-bridge-python-command "${config.modules.shell.python.finalPkg}/bin/python3")
          ${cfg.doom.confInit}
        '';
      };
    }
  ]);
}