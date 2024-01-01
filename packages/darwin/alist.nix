{
  lib,
  fetchurl,
  stdenv,
  installShellFiles,
  withBashCompletion ? false,
  withZshCompletion ? false,
  withFishCompletion ? false,
}:
stdenv.mkDerivation rec {
  pname = "alist";
  version = "3.29.1";
  src = fetchurl {
    url = "https://github.com/alist-org/alist/releases/download/v${version}/alist-darwin-arm64.tar.gz";
    sha256 = "sha256-eLbTBxtu+K+7jSw8T9yIYn8eDh+mHnZnX9RzFZbCyWU=";
  };
  sourceRoot = ".";
  buildInputs = [installShellFiles];
  # dontInstall = true;
  installPhase = ''
    install -D -m755 -t $out/bin alist
    ${lib.optionalString withBashCompletion ''
      installShellCompletion --cmd alist --bash <($out/bin/alist completion bash)
    ''}
    ${lib.optionalString withZshCompletion ''
      installShellCompletion --cmd alist --zsh <($out/bin/alist completion zsh)
    ''}
    ${lib.optionalString withFishCompletion ''
      installShellCompletion --cmd alist --fish <($out/bin/alist completion fish)
    ''}
  '';

  meta = with lib; {
    description = ''
      🗂️A file list program that supports multiple storage, powered by Gin and Solidjs.
    '';
    homepage = "https://github.com/alist-org/alist";
    platforms = platforms.darwin;
    maintainers = with maintainers; [shanyouli];
    license = licenses.gpl3;
  };
}
