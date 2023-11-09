{ fetchurl, lib, stdenv, fetchFromGitHub, unzip, enableZhwiki ? true  }:

let
  rimeDir = "share/rime-data";
in {
  cloverpinyin = stdenv.mkDerivation rec {
    name = "rime-cloverpinyin";
    version = "1.1.4";
    src = fetchurl {
      url = "https://github.com/fkxxyz/rime-cloverpinyin/releases/download/1.1.4/clover.schema-1.1.4.zip";
      sha256 = "sha256-Mn1qb5pndyRAGZzklh3a4KukAHgoUSLTJ1hP8Rb9R4s=";
    };
    nativeBuildInputs = [ unzip ];
    sourceRoot = ".";
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      path="$out/${rimeDir}"
      mkdir -p $path
      cp -rvf * $path
      ${lib.optionalString enableZhwiki ''
        sed -i "/- THUOCL_animal/a\ \ -\ zhwiki" $path/clover.dict.yaml
      ''}
      runHook postInstall
    '';
    meta = {
      homepage = "https://github.com/fkxxyz/rime-cloverpinyin";
      description = "clover pinyin";
    };
  };
  prelude = stdenv.mkDerivation rec {
    name = "rime-prelude";
    version = "20201212";
    src = fetchFromGitHub {
      owner = "rime";
      repo = "rime-prelude";
      rev = "00a5b5a40b0e4419869ec3783744c75a8c86a5d7";
      sha256 = "sha256-Ixjqivva0D43gtoa0bWawljJ40D6SRvUFu1hOFqEuh8=";
    };
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      path="$out/${rimeDir}"
      mkdir -p $path
      cp -rvf *.yaml $path
      runHook postInstall
    '';
  };
  zhwiki = stdenv.mkDerivation rec {
    name = "zhwiki";
    version = "20201220";
    src = fetchurl {
      url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.1/zhwiki-20201220.dict.yaml";
      sha256 = "sha256-4XN+z25bGfjyzobCz1GkxaP/T1TxHt8H6I2+vkacI+w=";
    };
    # dontBuild = true;
    buildCommand = ''
      path="$out/${rimeDir}"
      mkdir -p $path
      install -v -m644 "$src" $path/zhwiki.dict.yaml
    '';
  };
}
