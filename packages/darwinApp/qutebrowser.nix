{ fetchurl, mkDarwinApp, ... }:

mkDarwinApp rec {
  appName = "qutebrowser";
  version = "2.5.3";
  src = fetchurl {
    url = "https://github.com/qutebrowser/qutebrowser/releases/download/v${version}/qutebrowser-${version}.dmg";
    sha256 = "1pnlkni4kykfa4skajlmc1q6radv4ywqp11hnhsi4prf29kcqw2g";
  };
  appMeta =  {
    description = "Keyboard-driven, vim-like browser based on PyQt5";
    homepage = "https://www.qutebrowser.org/";
  };
}
