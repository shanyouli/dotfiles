{
  lib,
  stdenv,
  ncurses,
  source,
}:
stdenv.mkDerivation rec {
  inherit (source) pname src version;
  buildInputs = [ncurses];
  configureFlags = ["--with-tcsetpgrp"];
  installPhase = ''
    install -D -m755 ./Src/zi/zpmod.so $out/lib/zi/zpmod.so
    mkdir -p $out/share/zpmod
    cat > $out/share/zpmod/zpmod.plugin.zsh <<EOF
    # Configuring environment variables for zmodule
    module_path+=( $out/lib )
    [[ -n "\$UNLOAD_ZPMOD" ]] || zmodload zi/zpmod
    EOF
  '';
  meta = with lib; {
    description = "Zsh module transparently and automatically compiles sourced scripts";
    homepage = "https://github.com/z-shell/zpmod";
    license = licenses.gpl2; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [lyeli];
    mainProgram = "zpmod";
    platforms = platforms.all;
  };
}
