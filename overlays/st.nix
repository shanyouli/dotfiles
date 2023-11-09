final: prev: {
  st = prev.st.overrideAttrs (oldAttrs: rec {
    src = prev.fetchFromGitHub {
      owner = "LukeSmithxyz";
      repo = "st";
      rev = "13b3c631be13849cd80bef76ada7ead93ad48dc6";
      sha256 = "sha256-xP2W9B1+vUe+RmNiYSaqXI45bY9Y6jB0XiIztJtRPwE=";
    };
    # Make sure you include whatever dependencies the fork needs to build properly!
    buildInputs = oldAttrs.buildInputs ++ [ prev.harfbuzz ];
  # If you want it to be always up to date use fetchTarball instead of fetchFromGitHub
  # src = pkgs.fetchTarball {
  #   url = "https://github.com/lukesmithxyz/st/archive/master.tar.gz";
  # };
  });
}
