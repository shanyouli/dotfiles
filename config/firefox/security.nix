{
  # Disable automatic updates.
  # Updates are no longer installed automatically. You will still be notified when
  # an update is available and can install it. Avoids getting a new (maybe addon
  # incompatible) version.
  "app.update.auto" = false;

  # Disable searching for updates.
  # Disable searching for updates. This only works with the enterprise policy
  # download..

  # Disable extension blocklist from mozilla.
  # The extension blocklist (https://blocked.cdn.mozilla.net/) is used by mozilla to
  # deactivate individual addons in the browser, but as a side effect it gives
  # mozilla the ultimate control to disable any extension. <b>Caution:</b> When you
  # disable the blocklist, you may keep using known malware addons.
  "extensions.blocklist.enabled" = false;
  # Enable HTTPS only mode
  # If enabled, allows connections only to sites that use the HTTPS protocol.
  "dom.security.https_only_mode" = true;
  "dom.security.https_only_mode_ever_enabled" = true;
  # Show Punycode.
  # This helps to protect against possible character spoofing.
  "network.IDN_show_punycode" = true;

  # 本 accounts-static.cdn.mozilla.net,accounts.firefox.com,addons.cdn.mozilla.net,addons.mozilla.org,api.accounts.firefox.com,content.cdn.mozilla.net,discovery.addons.mozilla.org,install.mozilla.org,oauth.accounts.firefox.com,profile.accounts.firefox.com,support.mozilla.org,sync.services.mozilla.com,autoatendimento.bb.com.br,ibpf.sicredi.com.br,ibpj.sicredi.com.br,internetbanking.caixa.gov.br,www.ib12.bradesco.com.br,www2.bancobrasil.com.br
  "extensions.webextensions.restrictedDomains" = "";
  "privacy.resistFingerprinting.block_mozAddonManager" = true;
}
