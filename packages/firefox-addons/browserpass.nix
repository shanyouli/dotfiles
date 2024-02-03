{
  buildFirefoxXpiAddon,
  lib,
}:
buildFirefoxXpiAddon
{
  pname = "browserpass";
  version = "3.8.0";
  addonId = "browserpass@maximbaz.com";
  url = "https://addons.mozilla.org/firefox/downloads/file/4187654/browserpass_ce-3.8.0.xpi";
  sha256 = "5291d94443be41a80919605b0939c16cc62f9100a8b27df713b735856140a9a7";
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
