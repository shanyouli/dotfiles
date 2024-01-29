{
  lib,
  buildGoModule,
  go,
  fuse,
  installShellFiles,
  withBashCompletion ? false,
  withZshCompletion ? false,
  withFishCompletion ? false,
  source,
  sources,
}: let
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;
  alist-web = sources.alist-web.src;
in
  buildGoModule rec {
    inherit version;
    inherit (source) pname src vendorHash;
    preBuild = ''
      rm -rf public/dist
      tar -zxvf ${alist-web}
      mv -f dist public
    '';
    ldflags = [
      "-s"
      "-w"
      "-X github.com/alist-org/alist/conf.GoVersion=go${go.version}"
      "-X github.com/alist-org/alist/conf.GitTag=${version}"
      "-X github.com/alist-org/alist/v3/internal/conf.WebVersion=${version}"
    ];
    # When a Go program depends on C libraries, place those dependencies in buildInputs:
    buildInputs = [fuse installShellFiles];
    postInstall = ''
      for i in $out/bin/* ; do
        if [[ $i != $out/alist* ]]; then
          rm -rf $i
        fi
      done
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
    checkFlags = let
      # Skip tests that require network access
      skippedTests = [
        "TestGetBalancedStorage"
        "TestWebsocketCaller"
        "TestWebsocketAll"
        "TestHTTPAll"
      ];
    in ["-skip=^${builtins.concatStringsSep "$|^" skippedTests}$"];
    # doCheck = false;
    tags = ["jsoniter"];
    meta = with lib; {
      description = "A file list/WebDAV program that supports multiple storages, powered by Gin and Solidjs. / 一个支持多存储的文件列表/WebDAV程序，使用 Gin 和 Solidjs";
      homepage = "https://github.com/alist-org/alist";
      license = licenses.agpl3Only;
      maintainers = with maintainers; [lyeli];
      mainProgram = "alist";
    };
  }
