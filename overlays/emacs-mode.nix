final: prev: let
  inherit (prev.lib) recurseIntoAttrs;
  emacsOverrides = eself: esuper: {
      _0xc = null;
      _2048-game = null;
      rime = let
        inherit (prev) librime brise;
      in esuper.rime.overrideAttrs (esuper: {
        buildInputs = (esuper.buildInputs or []) ++ [ librime brise ];
        postInstall = ''
          pushd source
          MODULE_FILE_SUFFIX=".so"
          make lib
          install -m444 -t $out/share/emacs/site-lisp/elpa/rime-** ./*.so
          rm -r $out/share/emacs/site-lisp/elpa/rime-*/{lib.c,Makefile}
          popd
        '';
      });
  };
in {
  emacsPackages =
    recurseIntoAttrs (prev.emacsPackages.overrideScope' emacsOverrides);
  emacsPackagesFor =
    emacs: recurseIntoAttrs ((prev.emacsPackagesFor emacs).overrideScope' emacsOverrides);
}
