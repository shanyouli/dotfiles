# 存在原因；
# 1. 使用符号连接，将所有 app 存放在 applications 上，spotilight 无法显示 应用
# 2. copy 的优点；使用 copy 将所有 gui.app 复制到指定位置，可以很好的解决该问题，
#    但占用内存过大，这也是 homebrew 使用的方法，
# 3. alias 缺点，
#    a. 使用该方法可以在 spotilight 上显示(但不再归类与应用)，
#    b. 软件更新后需要重新授权
#    c. 无法作为默认应用打开程序, 但有多个 app 版本时，使用 spotilight 或 raycast 打开
#       程序版本可能不是最新的版本，
#    d. 更新后，dock 上的图标也需要更新。
#    e. launchpad 上的图标很不好看。
#    优点： 占用内存很小。较为推荐
# 4. mac-app-util 方案 优点
#   a. 占用内存小
#   b. Pinning in Dock works across updates
#   C. 可以从 spotilight 启动
#   d. 是一个完成的 app
#
# 更多讨论见：@https://github.com/LnL7/nix-darwin/issues/214#issuecomment-2050027696
{
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfp = config.modules.macos;
  cfg = cfp.app;
in {
  options.modules.macos.app = {
    name = mkOpt' types.str "Myapps" "存放使用 nix 安装的 gui 程序目录名";
    user.enable = mkBoolOpt true; # 默认在家目录的 Applications/${cfg.name} 目录下
    path = mkOption {
      description = "将所有使用 nix 安装的文件存放在一个目录中.";
      type = types.path;
      visible = false;
      readOnly = true;
    };
    way = mkOption {
      description = "连接到一个目录的方法";
      type = types.str;
      default = "util";
      apply = s:
        if builtins.elem s ["copy" "alias" "util"]
        then s
        else "util";
    };
  };
  config = {
    modules.macos.app.path =
      if cfg.user.enable
      then "${homedir}/Applications/${cfg.name}"
      else "/Applications/${cfg.name}";
    home.initExtra = ''
      let homeManagerApps = ($env.HOME | path join "Applications" "Home Manager apps")
      if (($homeManagerApps | path type) == "symlink") {
         print $"(ansi green_bold)rmove Home Manager generation link.(ansi reset)"
          rm -rf $homeManagerApps
      }
    '';
  };
}
