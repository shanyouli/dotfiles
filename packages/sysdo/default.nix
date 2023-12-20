{
  python3,
  installShellFiles,
  stdenv,
  lib,
  withBashCompletion ? false,
  withZshCompletion ? false,
  withFishCompletion ? false,
  withRich ? false,
}: let
  pyEnv =
    python3.withPackages
    (ps: with ps; [typer colorama] ++ (lib.optionals withRich [rich])); # shellingham
in
  stdenv.mkDerivation rec {
    pname = "sysdo";
    version = "0.5";
    src = ./.;
    buildInputs = [pyEnv installShellFiles];
    installPhase = ''
      install -D -m755 do.py $out/bin/sysdo
      substituteInPlace $out/bin/sysdo --replace "/usr/bin/env python3" ${pyEnv}/bin/python
      ${lib.optionalString withBashCompletion ''
        installShellCompletion --cmd sysdo --bash <($out/bin/sysdo --show-completion bash)
      ''}
      ${lib.optionalString withZshCompletion ''
        installShellCompletion --cmd sysdo --zsh <($out/bin/sysdo --show-completion zsh)
      ''}
      ${lib.optionalString withFishCompletion ''
        installShellCompletion --cmd sysdo --fish <($out/bin/sysdo --show-completion fish)
      ''}
    '';
    meta = with lib; {
      description = ''NIX Configuration Management Tools'';
      # homepage = "";
      platforms = platforms.all;
      maintainers = with maintainers; [shanyouli];
      license = licenses.gpl3;
    };
  }
