{
  lib,
  buildGoModule,
  source,
}:
buildGoModule rec {
  inherit (source) pname src vendorHash;
  version =
    if (builtins.hasAttr "date" source)
    then source.date
    else lib.removePrefix "v" source.version;

  ldflags = ["-s" "-w"];
  postInstall = ''
    mv $out/bin/DeepLX $out
    mv $out/DeeplX $out/bin/deeplx
  '';
  meta = with lib; {
    description = "DeepL Free API (No TOKEN required";
    homepage = "https://github.com/OwO-Network/DeepLX";
    license = licenses.mit;
    maintainers = with maintainers; [lyeli];
    mainProgram = "deeplx";
  };
}
