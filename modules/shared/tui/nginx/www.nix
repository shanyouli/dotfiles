{
  pkgs,
  lib,
  config,
  options,
  my,
  ...
}:
with lib;
with my; let
  cfp = config.modules.nginx;
  cfg = cfp.www;
  cfghtml = pkgs.writeText "index.html" ''
    <!DOCTYPE html>
    <html>
      <head>
        <title>Home</title>
        <meta charset="UTF-8" />
        <link rel="stylesheet" type="text/css" href="style.css" />
        <link rel="shortcut icon" href="favicon.png" />
      </head>
      <body>
        <div class="everything">
          <div id="time" class="time"></div>
          <form id="search-form" method="GET">
            <select id="search-engine" name="engine">
              <option value="https://www.bing.com/search">Bing</option>
              <option value="https://www.google.com/search">Google</option>
              <option value="https://www.baidu.com/s" selected>Baidu</option>
              <option value="https://metaso.cn/">秘塔 AI</option>
            </select>
            <input
              autofocus
              name="q"
              class="search"
              type="search"
              id="search-bar-input"
              placeholder="Search..."
            />
            <button type="submit">Search</button>
          </form>
          <!-- <form action="https://bing.com/search" method="GET">
               <input
               autofocus
               name="q"
               class="search"
               type="search"
               id="search-bar-input"
               placeholder=""
               />
               </form> -->
          <div class="box">
            <div class="link">
              <ul>
                <li><a href="https://github.com">github</a></li>
                <li><a href="https://linux.do">Linux.Do</a></li>
                <li><a href="https://emacs-china.org">Emacs China</a></li>
                <li><a href="https://miniflux.shanyouli.gq">RSS</a></li>
                <li><a href="https://bm.shanyouli.gq">Bookmark</a></li>
              </ul>
            </div>
            <div class="link">
              <ul>
                <li><a href="https://youtube.com">youtube</a></li>
                <li><a href="https://bilibili.com">bilibili</a></li>
                <li><a href="https://soupian.pro/">搜片</a></li>
              </ul>
            </div>
            <div class="link">
              <ul>
                ${optionalString config.modules.proxy.service.enable ''<li><a href="http://127.0.0.1/proxy/">Proxy UI</a></li>''}
                ${optionalString config.modules.alist.service.enable ''<li><a href="http://127.0.0.1/alist">Alist</a></li>''}
                ${optionalString config.modules.download.aria2.service.enable ''<li><a href="http://127.0.0.1/aria2">Aria2</a></li>''}
                ${optionalString config.modules.app.qbittorrent.service.enable ''<li><a href="http://127.0.0.1/qt">Qbittorrent UI</a></li>''}
              </ul>
            </div>
            <!-- Feel free to add more divs here -->
          </div>
        </div>
        <script>
          function updateClock() {
            let date = new Date();
            let hours = date.getHours();
            let minutes = date.getMinutes();
            let ampm = hours >= 12 ? "pm" : "am";
            hours = hours % 12;
            hours = hours ? hours : 12;
            minutes = minutes < 10 ? "0" + minutes : minutes;
            let time = hours + ":" + minutes + " " + ampm;
            document.getElementById("time").innerHTML = time;
            setTimeout(updateClock, 1000);
          };
          function searchBox() {
            document.getElementById('search-form').addEventListener('submit', function(event) {
              event.preventDefault();
              const form = event.target;
              const selectedEngine = form.engine.value;
              const query = form.q.value;
              let url;
              if (selectedEngine === 'https://www.baidu.com/s') {
                url = `''${selectedEngine}?wd=''${encodeURIComponent(query)}`;
              } else {
                url = `''${selectedEngine}?q=''${encodeURIComponent(query)}`;
              }
              window.location.href = url;
            })
          };
          window.onload = function() {
            document.getElementById('search-bar-input').focus();
            updateClock();
            searchBox();
          };
        </script>
      </body>
    </html>
  '';
in {
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
        source = "${my.dotfiles.config}/startpage";
      };
      ".cache/startpage/index.html".source = cfghtml;
    };
  };
}
