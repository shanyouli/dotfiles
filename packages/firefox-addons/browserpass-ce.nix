{
  mkFirefoxAddon,
  lib,
  source,
  fetchurl,
}:
mkFirefoxAddon
{
  inherit (source) pname version;
  addonId = "browserpass@maximbaz.com";
  src = fetchurl {inherit (source) url sha256;};
  meta = with lib; {
    homepage = "https://github.com/browserpass/browserpass-extension";
    description = "Browserpass is a browser extension for Firefox and Chrome to retrieve login details from zx2c4's pass (<a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/fcd8dcb23434c51a78197a1c25d3e2277aa1bc764c827b4b4726ec5a5657eb64/http%3A//passwordstore.org\" rel=\"nofollow\">passwordstore.org</a>) straight from your browser. Tags: passwordstore, password store, password manager, passwordmanager, gpg";
    license = licenses.isc;
    mozPermissions = [
      "activeTab"
      "alarms"
      "tabs"
      "clipboardRead"
      "clipboardWrite"
      "nativeMessaging"
      "notifications"
      "webRequest"
      "webRequestBlocking"
      "http://*/*"
      "https://*/*"
    ];
    platforms = platforms.all;
  };
}
