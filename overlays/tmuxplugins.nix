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
  };
}
