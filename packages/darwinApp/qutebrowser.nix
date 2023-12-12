{
  fetchurl,
  mkDarwinApp,
  ...
}:
mkDarwinApp rec {
  appName = "qutebrowser";
  version = "3.1.0";
  src = fetchurl {
    url = "https://github.com/qutebrowser/qutebrowser/releases/download/v${version}/qutebrowser-${version}.dmg";
    sha256 = "1db31lndbpxn6rbwhk2sbp6j50pz9d8knzs6gbvclcgi970sxyq2";
  };
  appMeta = {
    description = "Keyboard-driven, vim-like browser based on PyQt5";
    homepage = "https://www.qutebrowser.org/";
  };
}
