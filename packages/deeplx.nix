{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "deeplx";
  version = "0.8.8";

  src = fetchFromGitHub {
    owner = "OwO-Network";
    repo = "DeepLX";
    rev = "v${version}";
    hash = "sha256-4/sfePuNS67tlyt0KGqLiYXfTu5uvHS2+XD8X5IrROo=";
  };

  vendorHash = "sha256-x4Z8fTrgXOH+9Ixj9NKr2G3BuQPm7/CqNGoIVbXmMOE=";
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
