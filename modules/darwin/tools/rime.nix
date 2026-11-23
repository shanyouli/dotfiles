{
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfg = config.modules.macos.tools.rime;
  rime = config.modules.tools.rime;
  reload = "'/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel' --reload";

  # 配色参考 https://ssnhd.com/2022/01/11/rime-skin/
  # 三套配色共用的布局和文字颜色。
  scheme-common = {
    candidate_format = "%c %@ ";
    corner_radius = 5;
    line_spacing = 10;
    font_face = "PingFangSC";
    font_point = 16;
    label_font_point = 13;
    text_color = "0x424242";
    label_color = "0x999999";
    comment_text_color = "0x999999";
    hilited_text_color = "0x999999";
    hilited_candidate_text_color = "0xFFFFFF";
    hilited_candidate_label_color = "0xFFFFFF";
    hilited_comment_text_color = "0x999999";
  };
  # 浅色与深色方案额外设置高亮圆角和窗口留白。
  standard-layout = {
    hilited_corner_radius = 5;
    border_height = 4;
    border_width = 4;
    hilited_back_color = "0xD75A00";
  };
  mac-light =
    scheme-common
    // standard-layout
    // {
      name = "Mac浅色";
      back_color = "0xFFFFFF";
      border_color = "0xFFFFFF";
      candidate_text_color = "0x3c3c3c";
    };
  mac-dark =
    scheme-common
    // standard-layout
    // {
      name = "Mac深色";
      back_color = "0x252a2e";
      border_color = "0x050505";
      candidate_text_color = "0xe9e9ea";
    };
  default-patch = {
    "style/color_scheme" = "mac_light";
    "style/color_scheme_dark" = "mac_dark";
    "style/text_orientation" = "horizontal";
    "style/candidate_list_layout" = "linear";
    app_options = {
      "com.google.Chrome".inline = true; # https://github.com/rime/squirrel/issues/435
      "ru.keepcoder.Telegram".inline = true; # https://github.com/rime/squirrel/issues/475
      "org.gnu.Emacs" = {
        ascii_mode = true;
        no_inline = true;
      };
    };
    "preset_color_schemes/+" = {
      mac_light = mac-light;
      mac_dark = mac-dark;
    };
  };
in
{
  options.modules.macos.tools.rime = {
    enable = mkBoolOpt rime.enable;
    patch.squirrel = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      apply = recursiveUpdate default-patch;
      description = "squirrel.custom.yaml 的 patch 覆盖项，保留未指定的默认字段";
    };
  };

  config = mkIf cfg.enable {
    # macOS 侧系统 rime 目录（Squirrel）完全由本开关控制：关闭时不生成 ~/Library/Rime 下任何文件
    modules.tools.rime.server.dir = mkDefault "Library/Rime";
    home.file."Library/Rime" = {
      source = "${rime.dataPkg}/share/rime-data/";
      recursive = true;
      onChange = reload;
    };
    home.file."Library/Rime/squirrel.custom.yaml".source = toYamlFile { patch = cfg.patch.squirrel; };
    homebrew.casks = [ "squirrel-app" ];
    modules.tools.rime.backup.enable = mkDefault true;
  };
}
