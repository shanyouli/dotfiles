final: prev:  {
# @https://github.com/eraserhd/tmux-plumb/blob/develop/overlay.nix
  tmuxPlugins = prev.tmuxPlugins // {
    gruvbox = prev.tmuxPlugins.gruvbox.overrideAttrs (oldAttrs: rec {
      version = "20201105";
      src = prev.fetchFromGitHub {
        owner = "egel";
        repo = "tmux-gruvbox";
        rev = "ccab926b566560b0138c6fee86985f2dfc21454a";
        sha256 = "sha256-Z/qvHbRMy2fIlwlfVw6i5KIEwl6OEYm99LghO/qY8Cs=";
      };
    });
    open = prev.tmuxPlugins.open.overrideAttrs (oldAttrs: rec {
      version = "20200808";
      src = prev.fetchFromGitHub {
        owner = "tmux-plugins";
        repo = "tmux-open";
        rev = "5b09bd955292ae33ef6d3519df09b5bc1b0ff49e";
        sha256 = "sha256-sndbrD4wK5zLPHgMBpvZyM9cPo2pST6fVvPg7QtaE/c=";
      };
    });
  };
}
