{ stdenv, installShellFiles, lib, ncurses, zsh, asciidoc-full, fetchFromGitHub,}:
# see https://github.com/sei40kr/dotfiles/blob/master/packages/zinit.nix
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/shells/zsh/zplugin/default.nix
stdenv.mkDerivation rec {
  pname = "zinit";
  version = "3.7";
  src = fetchFromGitHub {
    owner = "zdharma";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-B+cTGz+U8MR22l6xXdRAAjDr+ulCk+CJ9GllFMK0axE=";
  };
  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ zsh ncurses asciidoc-full ];
  configurePhase = ''
    pushd zmodules
    ./configure --with-tcsetpgrp
    popd
  '';
  buildPhase = ''
    ${zsh}/bin/zsh -c 'zcompile zinit.zsh'
    ${zsh}/bin/zsh -c 'zcompile zinit-side.zsh'
    ${zsh}/bin/zsh -c 'zcompile zinit-install.zsh'
    ${zsh}/bin/zsh -c 'zcompile zinit-autoload.zsh'
    ${zsh}/bin/zsh -c 'zcompile git-process-output.zsh'
    ${zsh}/bin/zsh -c 'zcompile zinit-additional.zsh'
    pushd zmodules
    make
    popd

    pushd zsdoc
    make man/zinit.zsh.1 man/zinit-install.zsh.1 man/zinit-side.zsh.1
    # TODO: FIXME: make man/zinit-autoload.zsh.1 error
    # make man/zinit-autoload.zsh.1 # error
    popd
  '';

    installPhase = ''
      runHook preInstall
      outdir="$out/share/$pname"
      install -dm0755 "$outdir"
      install -m0644 zinit{,-side,-install,-autoload,-additional}.zsh{,.zwc} "$outdir"
      install -m0755 git-process-output.zsh "$outdir"
      # Zplugin autocompletion
      installShellCompletion --zsh _zinit

      mkdir -p $outdir/zsh/zdharma
      install -m0755 zmodules/Src/zdharma/zplugin.so "$outdir/zsh/zdharma"

      mkdir -p $out/share/man/man1
      cp -rf zsdoc/man/* $out/share/man/man1
      cp -rv doc/zinit.1 $out/share/man/man1
      find share/ -type d -exec install -dm 755 "{}" "$outdir/{}" \;
      find share/ -type f -exec install -m 744 "{}" "$outdir/{}" \;
      runHook postInstall
    '';
    meta = with lib; {
      description =
        "Ultra-flexible and fast Zsh plugin manager with clean fpath, reports, completion management, Turbo, annexes, services, packages.";
      homepage = "https://zdharma.org/zinit/wiki/";
      license = licenses.mit;
      platforms = platforms.all;
    };
}
