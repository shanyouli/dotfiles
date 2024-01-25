{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  duti,
}:
buildGoModule rec {
  pname = "dutis";
  version = "unstable-2023-09-27";

  src = fetchFromGitHub {
    owner = "tsonglew";
    repo = "dutis";
    rev = "e8f8d6176fff1b42e7e68a552fcfd2923f9c27a2";
    hash = "sha256-mwIBWLKUbqINPc1SnsMHVaN+5sXlRvC20M6kv9DAa5I=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-lUBSQq4ac/Vc76gmSaKFkfCrO/BmhQU+3UyA+URb8l8=";

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
