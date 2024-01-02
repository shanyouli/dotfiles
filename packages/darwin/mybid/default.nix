{
  python3,
  installShellFiles,
  stdenv,
  lib,
  withBashCompletion ? false,
  withZshCompletion ? true,
  withFishCompletion ? false,
  withRich ? false,
}: let
  pyEnv = python3.withPackages (ps: with ps; [typer colorama] ++ (lib.optionals withRich [rich]));
in
  stdenv.mkDerivation rec {
    pname = "mybid";
    version = "0.2";
    src = ./.;
    buildInputs = [pyEnv installShellFiles];
    installPhase = ''
      install -D -m755 getBundleId.py $out/bin/mybid
      substituteInPlace $out/bin/mybid --replace "/usr/bin/env python3" ${pyEnv}/bin/python
      ${lib.optionalString withBashCompletion ''
        installShellCompletion --cmd mybid --bash <($out/bin/mybid --show-completion bash)
      ''}
      ${lib.optionalString withZshCompletion ''
        installShellCompletion --cmd mybid --zsh <($out/bin/mybid --show-completion zsh)
      ''}
      ${lib.optionalString withFishCompletion ''
        installShellCompletion --cmd mybid --fish <($out/bin/mybid --show-completion fish)
      ''}
    '';
    meta = with lib; {
      description = ''Get MacApp BundleId'';
      # homepage = "";
      platforms = platforms.all;
      maintainers = with maintainers; [shanyouli];
      license = licenses.gpl3;
    };
  }
