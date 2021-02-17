{buildGoModule, fetchFromGitHub, makeWrapper, xray-asset, }:

buildGoModule rec {
  pname = "xray";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "XTLS";
    repo = "Xray-core";
    rev = "v${version}";
    sha256 = "sha256-HzduOdoJhLOLhE+pV0eHa+xuMLFl65ucpCuAj92dXKM=";
  };
  nativeBuildInputs = [ makeWrapper ];
  vendorSha256 = "sha256-ohZ6AWshLApJJHEhqtP4FOdmET6OndP08SU1+dXAmfk=";
  doCheck = false;
  buildPhase = ''
    buildFlagsArray=(-p $NIX_BUILD_CORES -ldflags="-s -w")
    runHook preBuild
    go build "''${buildFlagsArray[@]}" -o xray ./main
    runHook PostBuild
  '';
  installPhase = ''
    runHook preInstall
    install -Dm755 xray -t $out/bin
    wrapProgram $out/bin/${pname} \
      --set XRAY_LOCATION_ASSET "${xray-asset}/share/xray-asset"
    runHook postInstall
  '';
}
