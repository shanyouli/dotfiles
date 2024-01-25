{
  lib,
  buildGoModule,
  source,
}:
buildGoModule rec {
  inherit (source) pname version src vendorHash;

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
