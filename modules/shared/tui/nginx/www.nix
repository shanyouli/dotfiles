{
  pkgs,
  lib,
  config,
  my,
  ...
}:
with lib;
with my;
let
  cfp = config.modules.nginx;
  cfg = cfp.www;

  /*
    -----------------------------------------------------------------------
    搜索引擎列表

    每个元素：
      name     - 显示名称
      url      - 搜索 URL（不含参数）
      param    - 搜索参数名（如 wd、q、question）
      default  - 是否默认选中（最多一项为 true）
    -----------------------------------------------------------------------
  */
  searchEngines = [
    {
      name = "Bing";
      url = "https://www.bing.com/search?q=";
      default = false;
    }
    {
      name = "Google";
      url = "https://www.google.com/search?q=";
      default = false;
    }
    {
      name = "Baidu";
      url = "https://www.baidu.com/s?wd=";
      default = true;
    }
    {
      name = "秘塔 AI";
      url = "https://metaso.cn/?question=";
      default = false;
    }
  ];

  /**
    生成 <option> 列表字符串
  */
  searchEngineOptions = lib.concatStringsSep "\n          " (
    map (
      e: "<option value=\"${e.url}\"${lib.optionalString e.default " selected"}>${e.name}</option>"
    ) searchEngines
  );

  /*
    -----------------------------------------------------------------------
    链接组 — 数据驱动所有 <div class="link"> 区块

    每个元素：
      name     - 链接显示的文本
      url      - 目标 URL
      enable?  - 可选条件开关（默认 true）
    -----------------------------------------------------------------------
  */
  linkGroup1 = [
    {
      name = "github";
      url = "https://github.com";
    }
    {
      name = "Linux.Do";
      url = "https://linux.do";
    }
    {
      name = "Emacs China";
      url = "https://emacs-china.org";
    }
    {
      name = "RSS";
      url = "https://miniflux.shanyouli.gq";
    }
    {
      name = "Bookmark";
      url = "https://bm.shanyouli.gq";
    }
  ];

  linkGroup2 = [
    {
      name = "YouTube";
      url = "https://www.youtube.com";
    }
    {
      name = "Bilibili";
      url = "https://www.bilibili.com";
    }
    {
      name = "搜片";
      url = "https://soupian.pro/";
    }
  ];

  linkGroup3 = [
    {
      name = "Proxy UI";
      url = "http://127.0.0.1/proxy/";
      enable = config.modules.proxy.service.enable;
    }
    {
      name = "Alist";
      url = "http://127.0.0.1/alist";
      enable = config.modules.alist.service.enable;
    }
    {
      name = "Aria2";
      url = "http://127.0.0.1/aria2";
      enable = config.modules.download.aria2.service.enable;
    }
    {
      name = "Qbittorrent UI";
      url = "http://127.0.0.1/qt";
      enable = config.modules.app.qbittorrent.service.enable;
    }
  ];

  /**
    将一个链接组渲染为 <div class="link"><ul>…</ul></div> 片段。
    自动跳过 enable = false 的条目。
  */
  renderLinkGroup =
    group:
    let
      items = lib.concatStringsSep "\n            " (
        map (link: "<li><a href=\"${link.url}\">${link.name}</a></li>") (filter (x: x.enable or true) group)
      );
    in
    ''
      <div class="link">
        <ul>${if items == "" then "" else "\n            " + items + "\n          "}</ul>
      </div>
    '';

  /**
    将所有链接组拼接为一个 HTML 字符串
  */
  linkGroupsString = lib.concatStringsSep "\n        " (
    map renderLinkGroup [
      linkGroup1
      linkGroup2
      linkGroup3
    ]
  );

  /*
    -----------------------------------------------------------------------
    模板 → 最终 HTML
    -----------------------------------------------------------------------
  */
  template = builtins.readFile "${my.paths.dotfiles.config}/startpage/index.html";

  cfghtml = pkgs.writeText "index.html" (
    lib.replaceStrings
      [ "__SEARCH_ENGINES__" "__LINK_GROUPS__" ]
      [ searchEngineOptions linkGroupsString ]
      template
  );
in
{
  options.modules.nginx.www = {
    enable = mkEnableOption "Whether to use startpage";
  };

  config = mkIf cfg.enable {
    modules.gui.browser.firefox.extraConfig = ''
      user_pref("browser.startup.homepage", "http://127.0.0.1");
    '';

    home.file = {
      ".cache/startpage" = {
        recursive = true;
        source = pkgs.runCommand "startpage" { } ''
          cp -r ${my.paths.dotfiles.config}/startpage $out
          chmod +w $out
          cp -f ${cfghtml} $out/index.html
        '';
      };
    };
  };
}
