{ runCommand, fetchurl }:
let
  version = "3.0.2";
  pname = "sigwriting";
  baseUrl = "https://github.com/Slevinski/signwriting_2010_fonts";
in runCommand "${pname}-${version}" {
  src1 = fetchurl {
    url = "${baseUrl}/raw/v${version}/fonts/SignWriting%202010.ttf";
    name = "SignWriting_2010.ttf";
    sha256 = "sha256-8hc34eUZCKmchDhZPxVBeGy6dg7l9lwRVVB0uab/cqk=";
    # sha256 = "sha256-VXDZDRPgz4rjDx6CXI9cu7NU0nCF6TX718k3edzipSo=";
  };
  src2 = fetchurl {
    url = "${baseUrl}/raw/v${version}/fonts/SignWriting%202010%20Filling.ttf";
    name = "SignWriting_2010_Filling.ttf";
    sha256 = "sha256-VXDZDRPgz4rjDx6CXI9cu7NU0nCF6TX718k3edzipSo=";
  };
  src3 = fetchurl {
    url = "${baseUrl}/raw/v${version}/fonts/SuttonSignWriting.ttf";
    name = "SuttonSignWriting.ttf";
    sha256 = "sha256-7bmOYJiqU1BvEeie0Bkc84rUXoNV27dylQKwcP6inbM=";
  };

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  # outputHash = "sha256-ViVKapR3MGQ5Awh3FlMvWf+czgRHCi5owuqpwQ+45Lg=";
} ''
  prefix=$out/share/fonts/truetype
  mkdir -p $prefix
  cp $src1 $prefix/SignWriting_2010.ttf
  cp $src2 $prefix/SignWriting_2010_filling.ttf
  cp $src3 $prefix/SutonSignWriting.ttf
''
