{buildGoModule, fetchFromGitHub,}:

buildGoModule rec {
  pname = "Xray-core";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "XTLS";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-HzduOdoJhLOLhE+pV0eHa+xuMLFl65ucpCuAj92dXKM=";
  };
  vendorSha256 = "sha256-ohZ6AWshLApJJHEhqtP4FOdmET6OndP08SU1+dXAmfk=";
  doCheck = false;
  buildPhase = ''
    buildFlagsArray=(-p $NIX_BUILD_CORES -ldflags="-s -w")
    runHook preBuild
    go build "''${buildFlagsArray[@]}" -o xray ./main
    runHook PostBuild
  '';
  installPhase = ''
    install -Dm755 xray -t $out/bin
  '';
}
