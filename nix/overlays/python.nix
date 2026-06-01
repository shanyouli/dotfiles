_final: prev:
(
  let
    packageOverrides = _pfinal: pprev: {
      # gssapi = inputs.nurpkgs.packages.${prev.system}.python-apps-gssapi;
      aria2p = pprev.aria2p.overrideAttrs (_old: {
        doCheck = false;
        doInstallCheck = false;
      });
      pipx = pprev.pipx.overrideAttrs (_old: {
        # pipx 1.8.0 在当前 Python/packaging 组合下的上游测试会失败。
        doCheck = false;
        doInstallCheck = false;
      });
    };
  in
  rec {
    python3 = prev.python3.override { inherit packageOverrides; };
    python3Packages = python3.pkgs;

    pypy3 = prev.python3.override { inherit packageOverrides; };
    pypy3Packages = pypy3.pkgs;

    python310 = prev.python310.override { inherit packageOverrides; };
    python310Packages = python310.pkgs;
  }
)
