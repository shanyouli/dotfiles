final: prev: {
  polybar = prev.polybar.overrideAttrs (oldAttrs: rec {
    version = "3.5.4";
    src = prev.fetchFromGitHub {
      owner = oldAttrs.pname;
      repo = oldAttrs.pname;
      rev = version;
      sha256 = "sha256-UAomGv0urHAI9W7v6gxcSevwnnrdILKrg9FRCYJb9uU=";
      fetchSubmodules = true;
    };
  });
}
