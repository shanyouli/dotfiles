{
  mkFirefoxAddon,
  lib,
  source,
  fetchurl,
}:
mkFirefoxAddon
{
  inherit (source) pname version;
  src = fetchurl {inherit (source) url sha256;};
  addonId = "{73a6fe31-595d-460b-a920-fcc0f8843232}";
  meta = with lib; {
    homepage = "https://noscript.net/";
    description = "NoScript Security Suite";
    license = licenses.gpl2;
    mozPermissions = [
      "contextMenus"
      "storage"
      "tabs"
      "unlimitedStorage"
      "webNavigation"
      "webRequest"
      "webRequestBlocking"
      "dns"
      "<all_urls>"
      "file://*/*"
      "ftp://*/*"
    ];
    platforms = platforms.all;
  };
}
