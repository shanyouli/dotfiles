{
  lib,
  buildGoModule,
  makeWrapper,
  duti,
  source,
}:
buildGoModule rec {
  inherit (source) pname version src vendorHash;

  nativeBuildInputs = [makeWrapper];

  ldflags = ["-s" "-w"];
  doCheck = false;
  postInstall = ''
    wrapProgram $out/bin/dutis \
      --prefix PATH : ${lib.makeBinPath [duti]}
  '';
  meta = with lib; {
    description = "A command-line tool to select default applications, based on duti";
    homepage = "https://github.com/tsonglew/dutis";
    license = licenses.mit;
    maintainers = with maintainers; [lyeli];
    platforms = platforms.darwin;
    mainProgram = "dutis";
  };
}
