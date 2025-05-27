{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.shell;
  shell_list = [
    "zsh"
    "bash"
    "nu"
    "fish"
  ];
  my-nix-script = pkgs.stdenv.mkDerivation rec {
    name = "nix-scripts";
    src = relativeToRoot "bin";
    buildInputs = [ ];
    installPhase = ''
      mkdir -p $out/bin
      find . -maxdepth 1 -perm -a+x -not -name '*.*' \
        -exec cp -pL {} $out/bin \;
    '';

    meta = with lib; {
      description = "my scripts bin";
      homepage = "https://github.com/shanyouli/system";
      license = licenses.mit;
      maintainers = with maintainers; [ shanyouli ];
      platforms = platforms.all;
    };
  };
in
{
  options.modules.shell = with types; {
    default = mkOption {
      description = "use default shell";
      type = types.str;
      default = "zsh";
      apply = s: if builtins.elem s shell_list then s else "zsh";
    };
    aliases = mkOpt (attrsOf (either str path)) { };
    env = mkOption {
      type = attrsOf (oneOf [
        str
        path
        (listOf (either str path))
      ]);
      default = { };
      description = "TODO";
    };
  };
  config = {
    home.packages = with pkgs; [
      my-nix-script
      grc
      httrack # 网页抓取
      cachix # nix cache
      hugo # 我的blog工具
      imagemagick # 图片转换工具

      # Terminal image viewer with native support for iTerm and Kitty
      # viu or timg,  timg better than viu。
      # support graphics see @https://sw.kovidgoyal.net/kitty/graphics-protocol/
      timg
      graphviz

      gifsicle # 命令行gif生成工具
      nix-your-shell # nix-shell Support for other shells(zsh,fish,nushell)
      gnused # sed 工具

      lnav # tailspin # 支持高亮的语法查看工具

      fzf
      my-nix-script
      pkgs.unstable.python3.pkgs.sd
      nvd
    ];
    env.PATH = [ ''''${XDG_BIN_HOME}'' ];

    modules.shell = {
      zsh.enable = mkDefault (cfg.default == "zsh");
      bash.enable = mkDefault (cfg.default == "bash");
      fish.enable = mkDefault (cfg.default == "fish");
      # nushell 目前不适合作为默认 shell 使用
      # nushell.enable = mkDefault (cfg.default == "nu");
    };
  };
}
