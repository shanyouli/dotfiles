// Encoding: UTF-8
const {
  aceVimMap,
  mapkey,
  imap,
  imapkey,
  getClickableElements,
  vmapkey,
  map,
  unmap,
  cmap,
  addSearchAlias,
  removeSearchAlias,
  tabOpenLink,
  readText,
  Clipboard,
  Front,
  Hints,
  Visual,
  iunmap,
  vunmap,
  RUNTIME,
} = api

// 设置默认的拨号键有asdfgqwertzxcvb
Hints.characters = 'asdfgqwertzxcvb';
// 拨号键靠左对齐
settings.hintAlign = "left";

settings.tabsThreshold = 15;
//无论是否在搜索栏里，标签页都按最近使用的顺序列出。如果你希望按标签页原本的顺序列出，可以设置：
// settings.tabsMRUOrder = false;

// 所有可以滚动的对象都默认支持顺滑滚动，如下可以关掉顺滑特性：
settings.smoothScroll = false;
// 默认输入框使用emacs按键
// //历史记录搜索，不使用默认的MU排序。MU排序太鸡肋。
settings.historyMUOrder = false;

//关于光标定位到地址栏无法定位回页面的问题。
//可以在浏览器设置里面添加特殊的搜索引擎来实现。搜索引擎的地址为javascript:  关键字设置为";" 最好关键字的中英文个添加一个搜索引擎。这样就很ok了。

//注意：与其他扩展的快捷键冲突问题。没有很好的实现。发现p按键，可以短暂失效按键捕获。只能说是一个方案，但是很鸡肋。比如和简悦的冲突。

// 1.冲突修改
//与浏览器冲突部分,个人认为它更好
// 移除与浏览器的冲突 查看下载历史，历史记录
unmap('<Ctrl-j>');
iunmap('<Ctrl-j>');
vunmap('<Ctrl-j>');
unmap('<Ctrl-h>');
iunmap('<Ctrl-h>');
vunmap('<Ctrl-h>');

settings.aceKeybindings = "vim";

// remove 一些默认的搜索按键
removeSearchAlias('b', 's');
removeSearchAlias('w', 's');
removeSearchAlias('h', 's');
removeSearchAlias('d', 's');
removeSearchAlias('e', 's');

// devv 开发问题AI回答
// d name, url, s, suggest-url, function back, only_this_site_key='o', url=
addSearchAlias('d', 'devv', "https://devv.ai/search/", 's',null, null, 'o', {favion_url: 'https://devv.ai/favicon.ico', skipMaps: false} );
// anybt bt搜索
addSearchAlias('D', "anybt", "https://anybt.eth.limo/#/search?q=", 's')
addSearchAlias('b', 'bing', 'https://www.bing.com/search?setmkt=en-us&setlang=en-us&q=', 's', 'https://api.bing.com/osjson.aspx?query=', function(response) {
    var res = JSON.parse(response.text);
    return res[1];
});
addSearchAlias('B', 'baidu', 'https://www.baidu.com/s?wd=', 's', 'https://suggestion.baidu.com/su?cb=&wd=', function(response) {
    var res = response.text.match(/,s:\[("[^\]]+")]}/);
    return res ? res[1].replace(/"/g, '').split(",") : [];
});

addSearchAlias('w', 'wikipedia', 'https://en.wikipedia.org/wiki/', 's', 'https://en.wikipedia.org/w/api.php?action=opensearch&format=json&formatversion=2&namespace=0&limit=40&search=', function(response) {
    return JSON.parse(response.text)[1];
});
addSearchAlias('G', 'github', 'https://github.com/search?q=', 's', 'https://api.github.com/search/repositories?order=desc&q=', function(response) {
    var res = JSON.parse(response.text)['items'];
    return res ? res.map(function(r){
        return {
            title: r.description,
            url: r.html_url
        };
    }) : [];
});

mapkey('p', '#0进入PassThrough模式', function() {
  api.Normal.passThrough(2000);
});

mapkey('ot', '打开onetab页面', function() {
  if (api.getBrowserName() === "Chrome") {
    tabOpenLink("chrome-extension://chphlpgkkbolifaimnlloiipkdnihall/onetab.html");
  } else {
    tabOpenLink("moz-extension://59b912fc-f318-419e-99a7-76469dc200ce/onetab.html");
  }
});

mapkey(",ps", "打开浏览器设置", function() {
  tabOpenLink("about:preferences")
});

mapkey(',op', '打开pocket', function() {
  tabOpenLink("https://getpocket.com/my-list");
})

mapkey('ymo', '以org格式复制链接', () => {
  let url = document.URL;
  let title = document.title;
  let domain = document.domain;
  let message;
  if (domain === "github.com") {
    let urlEnd = url.replace("https://github.,com", "")
    if (title.startsWith(urlEnd, "")) {
      title = urlEnd.replace("/", "--");
    }
  } else if (domain === "movie.douban.com") {
    title = title.replace(" (豆瓣)","");
    let score = "",
        info = "";
    try {
      score = document.querySelector("div.rating_wrap:nth-child(1) > div:nth-child(2) > strong:nth-child(1)").textContent;
    } catch (err) {
      console.log("There's no way to find out the ratings.");
    }

    try {
      info = document.querySelector("#link-report-intra > span:nth-child(1)").textContent;
      info = info.replaceAll(" ", "").replace("\n", "");
    } catch (err) {
      console.log("No video information was found");
    }
    message = [
      "#+begin_quote",
      info,
      "#+end_quote",
      `- [[${url}][${title} 豆瓣评分:]] ${score}`,
      "- 我的评分:"
    ].join("\n")
  }
  if (message === undefined) {
    message = `[[${url}][${title}]]`
  }
  Clipboard.write(message)
});

mapkey('ymm', '以md格式复制链接', () => {
  let url = document.URL;
  let title = document.title;
  if (url.startsWith("https://github.com/")) {
    let urlEnd = url.replace("https://github.com/", "")
    if (title.startsWith(urlEnd, "")) {
      title = urlEnd.replace("/", "--");
    } else {
      console.log(urlEnd);
    }
  } else {
    console.log(url);
  }
  Clipboard.write(`[${title}](${url})`)
});

function  UrlExists(url){
  var  http = new  XMLHttpRequest();
  http.open('GET', url, false);
  http.send();
  return  http.status === 200;
}

mapkey("ymf", "复制网站ico", function() {
  let a = 0;
  let b = document.getElementsByTagName("link");
  let c = "";
  if (0 < b.length) {
    for (a = 0; a < b.length; a++) {
      if ("undefined" !== typeof b[a].rel && -1 < b[a].rel.indexOf("icon")) {
        c = b[a].href;
        break;
      }
    }
  }
  if ("" === c) {
    let url = "http://"+ window.location.host + "/favicon.ico"
    if (UrlExists(url)) {
      c = url;
    }
  }
  // https://www.google.com/s2/favicons?domain=domain
  if ("" === c) {
    console.log("Not Find favicon.ico");
    Front.showBanner("Not Find favicon.ico");
  } else {
    Clipboard.write(c)
  }
})

mapkey("yy", "复制URL", () => {
  let url = document.URL;
  if (document.domain === "github.com") {
    url = url.replace("\/blob\/", "\/raw\/")
  }
  Clipboard.write(url)
})

mapkey(',wv', "解除网页限制", function() {
  function t(e) {
    e.stopPropagation()
    e.stopImmediatePropagation && e.stopImmediatePropagation()
  };

  document.querySelectorAll("*").forEach(e => {
    "none" == window.getComputedStyle(e, null).getPropertyPriority("user-select") &&
      e.style.setProperty("user-select", "text", "important");
  });
  ["copy", "cut", "contextmenu", "selectstart", "mousedown", "mouseup", "mousemove", "keydown", "keypress", "keyup"].forEach(function(e) {
    document.documentElement.addEventListener(e, t, { capture: !0 })
  });
  Front.showBanner("解除当前网页复制限制")
})

mapkey('ymr', "RSS订阅", function() {
  if ((document.domain === "www.domp4.cc") || (document.domain == "www.mp4kan.com")) {
    let url = document.location.toString();
    let id = url.match(/([^\/]*)\.html/)[1];
    Clipboard.write(`https://rsshub.app/domp4/detail/${id}`)
  }
})

mapkey(",oc", "Org Capture", function() {
  location.href = 'org-protocol://capture?' +
    new URLSearchParams({
      template: 'pn',
      url: window.location.href,
      title: document.title,
      body: window.getSelection(),
    });
  Front.showBanner("org Captured!")
})

// [[https://notes.fe-mm.com/efficiency/bookmark-scripts][书签脚本 | 茂茂物语]]
mapkey("op", "display password", function() {
  document.querySelectorAll('input[type=password]'.forEach(function(dom) {
    dom.setAttribute('type', 'text')
  }))
})

vmapkey("e", "Org Capture", function() {
  location.href = 'org-protocol://capture?' +
    new URLSearchParams({
      template: 'pn',
      url: window.location.href,
      title: document.title,
      body: window.getSelection(),
    });
  Front.showBanner("org Captured!")
})
// unmap("gg")
mapkey("gg", "scrool head", function() {
  document.scrollingElement.scrollIntoView({ behavior: 'smooth' })
})
mapkey("G", "移动到最下面", function() {
  document.scrollingElement.scrollIntoView({ behavior: 'smooth', block: "end" })
})
// api.vmapkey('c', 'send to emacs', function(){
//     javascript:location.href = 'org-protocol:///capture-html?template=w&url=' + encodeURIComponent(location.href) + '&title=' + encodeURIComponent(document.title || "[untitled page]") + '&body=' + encodeURIComponent(function () {var html = ""; if (typeof window.getSelection != "undefined") {var sel = window.getSelection(); if (sel.rangeCount) {var container = document.createElement("div"); for (var i = 0, len = sel.rangeCount; i < len; ++i) {container.appendChild(sel.getRangeAt(i).cloneContents());} html = container.innerHTML;}} else if (typeof document.selection != "undefined") {if (document.selection.type == "Text") {html = document.selection.createRange().htmlText;}} var relToAbs = function (href) {var a = document.createElement("a"); a.href = href; var abs = a.protocol + "//" + a.host + a.pathname + a.search + a.hash; a.remove(); return abs;}; var elementTypes = [['a', 'href'], ['img', 'src']]; var div = document.createElement('div'); div.innerHTML = html; elementTypes.map(function(elementType) {var elements = div.getElementsByTagName(elementType[0]); for (var i = 0; i < elements.length; i++) {elements[i].setAttribute(elementType[1], relToAbs(elements[i].getAttribute(elementType[1])));}}); return div.innerHTML;}());
// });

api.Front.registerInlineQuery({
  url: function(q) {
    return `http://dict.youdao.com/w/eng/${q}/#keyfrom=dict2.index`;
  },
  parseResult: function(res) {
    var parser = new DOMParser();
    var doc = parser.parseFromString(res.text, "text/html");
    var collinsResult = doc.querySelector("#collinsResult");
    var authTransToggle = doc.querySelector("#authTransToggle");
    var examplesToggle = doc.querySelector("#examplesToggle");
    if (collinsResult) {
      collinsResult.querySelectorAll("div>span.collinsOrder").forEach(function(span) {
        span.nextElementSibling.prepend(span);
      });
      collinsResult.querySelectorAll("div.examples").forEach(function(div) {
        div.innerHTML = div.innerHTML.replace(/<p/gi, "<span").replace(/<\/p>/gi, "</span>");
      });
      var exp = collinsResult.innerHTML;
      return exp;
    } else if (authTransToggle) {
      authTransToggle.querySelector("div.via.ar").remove();
      return authTransToggle.innerHTML;
    } else if (examplesToggle) {
      return examplesToggle.innerHTML;
    }
  }
});

// name: Rosé Pine Dawn
// author: thuanowa
// license: unlicense
// upstream: https://github.com/rose-pine/surfingkeys/blob/main/dist/rose-pine-dawn.conf
// blurb: All natural pine, faux fur and a bit of soho vibes for the classy minimalist

const hintsCss =
  "font-size: 13pt; font-family: 'JetBrains Mono NL', 'Cascadia Code', 'Helvetica Neue', Helvetica, Arial, sans-serif; border: 0px; color: #575279 !important; background: #faf4ed; background-color: #faf4ed";

api.Hints.style(hintsCss);
api.Hints.style(hintsCss, "text");

settings.theme = `
  .sk_theme {
    background: #faf4ed;
    color: #575279;
  }
  .sk_theme input {
    color: #575279;
  }
  .sk_theme .url {
    color: #907aa9;
  }
  .sk_theme .annotation {
    color: #d7827e;
  }
  .sk_theme kbd {
    background: #f2e9e1;
    color: #575279;
  }
  .sk_theme .frame {
    background: #fffaf3;
  }
  .sk_theme .omnibar_highlight {
    color: #dfdad9;
  }
  .sk_theme .omnibar_folder {
    color: #575279;
  }
  .sk_theme .omnibar_timestamp {
    color: #56949f;
  }
  .sk_theme .omnibar_visitcount {
    color: #56949f;
  }
  .sk_theme .prompt, .sk_theme .resultPage {
    color: #575279;
  }
  .sk_theme .feature_name {
    color: #575279;
  }
  .sk_theme .separator {
    color: #cecacd;
  }
  body {
    margin: 0;

    font-family: "JetBrains Mono NL", "Cascadia Code", "Helvetica Neue", Helvetica, Arial, sans-serif;
    font-size: 12px;
  }
  #sk_omnibar {
    overflow: hidden;
    position: fixed;
    width: 80%;
    max-height: 80%;
    left: 10%;
    text-align: left;
    box-shadow: 0px 2px 10px #f4ede8;
    z-index: 2147483000;
  }
  .sk_omnibar_middle {
    top: 10%;
    border-radius: 4px;
  }
  .sk_omnibar_bottom {
    bottom: 0;
    border-radius: 4px 4px 0px 0px;
  }
  #sk_omnibar span.omnibar_highlight {
    text-shadow: 0 0 0.01em;
  }
  #sk_omnibarSearchArea .prompt, #sk_omnibarSearchArea .resultPage {
    display: inline-block;
    font-size: 20px;
    width: auto;
  }
  #sk_omnibarSearchArea>input {
    display: inline-block;
    width: 100%;
    flex: 1;
    font-size: 20px;
    margin-bottom: 0;
    padding: 0px 0px 0px 0.5rem;
    background: transparent;
    border-style: none;
    outline: none;
  }
  #sk_omnibarSearchArea {
    display: flex;
    align-items: center;
    border-bottom: 1px solid #cecacd;
  }
  .sk_omnibar_middle #sk_omnibarSearchArea {
    margin: 0.5rem 1rem;
  }
  .sk_omnibar_bottom #sk_omnibarSearchArea {
    margin: 0.2rem 1rem;
  }
  .sk_omnibar_middle #sk_omnibarSearchResult>ul {
    margin-top: 0;
  }
  .sk_omnibar_bottom #sk_omnibarSearchResult>ul {
    margin-bottom: 0;
  }
  #sk_omnibarSearchResult {
    max-height: 60vh;
    overflow: hidden;
    margin: 0rem 0.6rem;
  }
  #sk_omnibarSearchResult:empty {
    display: none;
  }
  #sk_omnibarSearchResult>ul {
    padding: 0;
  }
  #sk_omnibarSearchResult>ul>li {
    padding: 0.2rem 0rem;
    display: block;
    max-height: 600px;
    overflow-x: hidden;
    overflow-y: auto;
  }
  .sk_theme #sk_omnibarSearchResult>ul>li:nth-child(odd) {
    background: #fffaf3;
  }
  .sk_theme #sk_omnibarSearchResult>ul>li.focused {
    background: #f2e9e1;
  }
  .sk_theme #sk_omnibarSearchResult>ul>li.window {
    border: 2px solid #cecacd;
    border-radius: 8px;
    margin: 4px 0px;
  }
  .sk_theme #sk_omnibarSearchResult>ul>li.window.focused {
    border: 2px solid #907aa9;
  }
  .sk_theme div.table {
    display: table;
  }
  .sk_theme div.table>* {
    vertical-align: middle;
    display: table-cell;
  }
  #sk_omnibarSearchResult li div.title {
    text-align: left;
  }
  #sk_omnibarSearchResult li div.url {
    font-weight: bold;
    white-space: nowrap;
  }
  #sk_omnibarSearchResult li.focused div.url {
    white-space: normal;
  }
  #sk_omnibarSearchResult li span.annotation {
    float: right;
  }
  #sk_omnibarSearchResult .tab_in_window {
    display: inline-block;
    padding: 5px;
    margin: 5px;
    box-shadow: 0px 2px 10px #f4ede8;
  }
  #sk_status {
    position: fixed;
    bottom: 0;
    right: 20%;
    z-index: 2147483000;
    padding: 4px 8px 0 8px;
    border-radius: 4px 4px 0px 0px;
    border: 1px solid #cecacd;
    font-size: 12px;
  }
  #sk_status>span {
    line-height: 16px;
  }
  .expandRichHints span.annotation {
    padding-left: 4px;
    color: #d7827e;
  }
  .expandRichHints .kbd-span {
    min-width: 30px;
    text-align: right;
    display: inline-block;
  }
  .expandRichHints kbd>.candidates {
    color: #575279;
    font-weight: bold;
  }
  .expandRichHints kbd {
    padding: 1px 2px;
  }
  #sk_find {
    border-style: none;
    outline: none;
  }
  #sk_keystroke {
    padding: 6px;
    position: fixed;
    float: right;
    bottom: 0px;
    z-index: 2147483000;
    right: 0px;
    background: #faf4ed;
    color: #575279;
  }
  #sk_usage, #sk_popup, #sk_editor {
    overflow: auto;
    position: fixed;
    width: 80%;
    max-height: 80%;
    top: 10%;
    left: 10%;
    text-align: left;
    box-shadow: #f4ede8;
    z-index: 2147483298;
    padding: 1rem;
  }
  #sk_nvim {
    position: fixed;
    top: 10%;
    left: 10%;
    width: 80%;
    height: 30%;
  }
  #sk_popup img {
    width: 100%;
  }
  #sk_usage>div {
    display: inline-block;
    vertical-align: top;
  }
  #sk_usage .kbd-span {
    width: 80px;
    text-align: right;
    display: inline-block;
  }
  #sk_usage .feature_name {
    text-align: center;
    padding-bottom: 4px;
  }
  #sk_usage .feature_name>span {
    border-bottom: 2px solid #cecacd;
  }
  #sk_usage span.annotation {
    padding-left: 32px;
    line-height: 22px;
  }
  #sk_usage * {
    font-size: 10pt;
  }
  kbd {
    white-space: nowrap;
    display: inline-block;
    padding: 3px 5px;
    font: 11px "JetBrains Mono NL", "Cascadia Code", "Helvetica Neue", Helvetica, Arial, sans-serif;
    line-height: 10px;
    vertical-align: middle;
    border: solid 1px #cecacd;
    border-bottom-lolor: #cecacd;
    border-radius: 3px;
    box-shadow: inset 0 -1px 0 #f4ede8;
  }
  #sk_banner {
    padding: 0.5rem;
    position: fixed;
    left: 10%;
    top: -3rem;
    z-index: 2147483000;
    width: 80%;
    border-radius: 0px 0px 4px 4px;
    border: 1px solid #cecacd;
    border-top-style: none;
    text-align: center;
    background: #faf4ed;
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;
  }
  #sk_tabs {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: transparent;
    overflow: auto;
    z-index: 2147483000;
  }
  div.sk_tab {
    display: inline-block;
    border-radius: 3px;
    padding: 10px 20px;
    margin: 5px;
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#faf4ed), color-stop(100%,#faf4ed));
    box-shadow: 0px 3px 7px 0px #f4ede8;
  }
  div.sk_tab_wrap {
    display: inline-block;
  }
  div.sk_tab_icon {
    display: inline-block;
    vertical-align: middle;
  }
  div.sk_tab_icon>img {
    width: 18px;
  }
  div.sk_tab_title {
    width: 150px;
    display: inline-block;
    vertical-align: middle;
    font-size: 10pt;
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;
    padding-left: 5px;
    color: #575279;
  }
  div.sk_tab_url {
    font-size: 10pt;
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;
    color: #907aa9;
  }
  div.sk_tab_hint {
    display: inline-block;
    float:right;
    font-size: 10pt;
    font-weight: bold;
    padding: 0px 2px 0px 2px;
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#faf4ed), color-stop(100%,#faf4ed));
    color: #575279;
    border: solid 1px #cecacd;
    border-radius: 3px;
    box-shadow: #f4ede8;
  }
  #sk_bubble {
    position: absolute;
    padding: 9px;
    border: 1px solid #cecacd;
    border-radius: 4px;
    box-shadow: 0 0 20px #f4ede8;
    color: #575279;
    background-color: #faf4ed;
    z-index: 2147483000;
    font-size: 14px;
  }
  #sk_bubble .sk_bubble_content {
    overflow-y: scroll;
    background-size: 3px 100%;
    background-position: 100%;
    background-repeat: no-repeat;
  }
  .sk_scroller_indicator_top {
    background-image: linear-gradient(#faf4ed, transparent);
  }
  .sk_scroller_indicator_middle {
    background-image: linear-gradient(transparent, #faf4ed, transparent);
  }
  .sk_scroller_indicator_bottom {
    background-image: linear-gradient(transparent, #faf4ed);
  }
  #sk_bubble * {
    color: #575279 !important;
  }
  div.sk_arrow>div:nth-of-type(1) {
    left: 0;
    position: absolute;
    width: 0;
    border-left: 12px solid transparent;
    border-right: 12px solid transparent;
    background: transparent;
  }
  div.sk_arrow[dir=down]>div:nth-of-type(1) {
    border-top: 12px solid #cecacd;
  }
  div.sk_arrow[dir=up]>div:nth-of-type(1) {
    border-bottom: 12px solid #cecacd;
  }
  div.sk_arrow>div:nth-of-type(2) {
    left: 2px;
    position: absolute;
    width: 0;
    border-left: 10px solid transparent;
    border-right: 10px solid transparent;
    background: transparent;
  }
  div.sk_arrow[dir=down]>div:nth-of-type(2) {
    border-top: 10px solid #575279;
  }
  div.sk_arrow[dir=up]>div:nth-of-type(2) {
    top: 2px;
    border-bottom: 10px solid #575279;
  }
  .ace_editor.ace_autocomplete {
    z-index: 2147483300 !important;
    width: 80% !important;
  }
  @media only screen and (max-width: 767px) {
    #sk_omnibar {
      width: 100%;
      left: 0;
    }
    #sk_omnibarSearchResult {
      max-height: 50vh;
      overflow: scroll;
    }
    .sk_omnibar_bottom #sk_omnibarSearchArea {
      margin: 0;
      padding: 0.2rem;
    }
  }
`;
