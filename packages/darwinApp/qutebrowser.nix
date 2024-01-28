{
  mkDarwinApp,
  source,
  ...
}:
mkDarwinApp rec {
  inherit (source) pname version src;
  meta = {
    description = "Keyboard-driven, vim-like browser based on PyQt5";
    homepage = "https://www.qutebrowser.org/";
  };
}
