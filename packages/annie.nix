{lib, buildGoModule, fetchFromGitHub, makeWrapper, ffmpeg }:
buildGoModule rec {
  pname = "annie";
  version = "0.10.3";
  src = fetchFromGitHub {
    owner = "iawia002";
    repo = pname;
    rev = version;
    sha256 = "sha256-Vp+Bwar/pPalobCJ2fzVSNtXGC6TnehKUq+DVTEkiS8=";
  };
  nativeBuildInputs = [ makeWrapper ];
  vendorSha256 = "sha256-clpE5rTpSpEiXAqx7MfURxL60EvPCJIMKTmro8mHgG4=";
  subPackages = [ "." ];
  runVend = true;
  doCheck = false;
  postInstall = let
    packagesToBinPath = [ ffmpeg ];
  in ''
    wrapProgram $out/bin/annie \
      --prefix PATH : ${lib.makeBinPath packagesToBinPath}
  '';
}
