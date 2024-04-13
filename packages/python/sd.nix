{
  lib,
  python3,
  installShellFiles,
  source,
}: let
  inherit (python3.pkgs) typer colorama rich buildPythonApplication poetry-core wcwidth; # rich 丰富色彩
in
  buildPythonApplication rec {
    version =
      if (builtins.hasAttr "date" source)
      then source.date
      else lib.removePrefix "v" source.version;
    inherit (source) pname src;
    pyproject = true;
    nativeBuildInputs = [poetry-core installShellFiles];
    propagatedBuildInputs = [typer colorama rich wcwidth];
    postInstall = ''
      installShellCompletion --cmd sd --bash <($out/bin/sd --show-completion bash)
      installShellCompletion --cmd sd --zsh <($out/bin/sd --show-completion zsh)
      installShellCompletion --cmd sd --fish <($out/bin/sd --show-completion fish)
    '';
    meta = with lib; {
      description = "My system command line";
      platforms = platforms.all;
      maintainers = with maintainers; [shanyouli];
      license = licenses.mit;
    };
  }
