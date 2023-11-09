{
  projectRootFile = "flake.nix";
  programs = {
    alejandra.enable = true;
    # black.enable = true;
    ruff.enable = true;
    gofmt.enable = true;
    prettier.enable = true;
    rufo.enable = true;
    shellcheck.enable = true;
    shfmt.enable = false;
    stylua.enable = true;
  };
}
