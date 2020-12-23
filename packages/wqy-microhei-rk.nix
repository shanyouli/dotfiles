{stdenv, dpkg, fetchurl }:
# 原版的 wqy-microhei 会使韩文字体挤在一起，无法观看，故使用 debian 修改的包
# 详情： https://packages.debian.org/jessie/fonts-wqy-microhei
# @see https://plumz.me/archives/11606/
# @see http://wenq.org/wqy2/index.cgi?MicroHei(en)
# @see https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=wqy-microhei-kr-patched

stdenv.mkDerivation rec {
  pname = "wqy-microhei";
  version = "0.2.0_beta";

  src = fetchurl {
    url = "http://ftp.cn.debian.org/debian/pool/main/f/fonts-wqy-microhei/fonts-wqy-microhei_0.2.0-beta-2_all.deb";
    sha256 = "sha256-UHyNO1gX5wtAdtr43ukTKktPASOn1s0FgcpdWE5V7tk=";
  };
  nativeBuildInputs = [ dpkg ];
  unpackPhase = "true";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts
    dpkg -x $src $out
    cp -rv $out/usr/share/fonts/truetype/wqy/wqy-microhei.ttc $out/share/fonts
    rm -rfv $out/usr
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "A font";
    longDescription = ''
      A Sans-Serif style high quality CJK outline font.Fix incorrect
      advanceWidths in hmtx for composite glyphs, which had caused Korean Hangul
      glyphs to stack on top of each other.
    '';
    homepage = "http://wenq.org/wqy2/index.cgi?MicroHei(en)";
    license = licenses.gpl3;
    maintainers = with maintainers; [ syl ];
    platforms = platforms.all;
  };
}
