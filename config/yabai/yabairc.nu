#!/usr/bin/env nu

use std log

sudo yabai --load-sa
yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

if (which borders | is-not-empty) {
  let borders_info = ps | where name == "borders"
  if ($borders_info | is-not-empty) {
    $borders_info | last | kill --force $in.pid
  } else {
    job spawn {
      borders active_color=0xff$CFORE inactive_color=0xff$CBACK width=5.0
     }
  }
}

# Do not manage windows with certain titles eg. Copying files or moving to bin
yabai -m rule --add title="(Copy|Bin|About This Mac|Info)" manage=off
# Do not manage some apps which are not resizable
yabai -m rule --add app="^(Calculator|System Preferences|[sS]tats|[Jj]et[Bb]rains [Tt]ool[Bb]ox|系统设置|System Settings|Hearthstone|Battle.net|Clash for Window|Dash|Ryujinx|OpenMTP|Tencent Lemon|Android File Transfer|BaiduNetdisk|Finder|VOX|mpv|Easydict)$" manage=off
yabai -m rule --add app="^(Simple Live)$" manage=off sub-layer=above
yabai -m rule --add title="^(.*[Cc]onsole|FloatTerm)$" manage=off
# if [[ $(yabai -m query --displays | jq -rj '. | length') -gt 1  ]]; then
#   yabai -m rule --add app="^Firefox$" display=2
# fi

yabai -m rule --add app="Parallels Desktop" title="Control Center" manage=off

yabai -m rule --add app="^PlantsVsZombiesRH$" opacity=1 manage=off grid=4:4:0:0:4:3

yabai -m rule --add app="^Safari$" title="(Passwords|General|Tabs|AutoFill|Search|Security|Privacy|Websites|Extensions|Advanced)" manage=off

yabai -m rule --add app="^(Nutstore|Karabiner-|GPG [Kk]eychain|IINA|Raycast|LuLu|DaisyDisk|Snapbox|MacZip|Archive Utility).*$" manage=off

# 视频播放程序,不透明度设置为1
yabai -m rule --add app="^([Mm]pv|IINA|VidHub|BaiduNetdisk)$" opacity=1

yabai -m rule --add title="Picture-in-Picture" opacity=1 manage=off

if ("/Applications/Hammerspoon.app" | path exists) {
  if (ps | where name == "Hammerspoon" | is-empty) {
    ^open -a /Applications/Hammerspoon.app
  }
  yabai -m rule --add app="^Hammerspoon$" manage=off sticky=on opacity=1
}


# 不需要自动聚焦，
# yabai -m signal --add event=window_destroyed \
#     action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus mouse"
# yabai -m signal --add event=application_terminated \
#     action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus mouse"

# yabai -m signal --add event=window_focused action=' \
#     win_info=$(yabai -m query --windows --window); \
#     is_floating=$(echo $win_info | jq -r ".\"is-floating\""); \
#     if [ "$is_floating" = "true" ]; then \
#         yabai -m window --opacity 1.0; \
#     else \
#         yabai -m window --opacity 0.98; \
#     fi'


# -------- yabai query helpers ----------
def yabai-spaces [] {
  ^yabai -m query --spaces | from json
}

def yabai-displays [] {
  ^yabai -m query --displays | from json
}

def yabai-display-space [dindex: int ] {
  ^yabai -m query --spaces --display $dindex | from json
}

# ----------------------- label normalization
def normalize-labels [labels] {
  match ($labels | describe) {
    "int" => { 1..$labels | each { |it|  $"No.($it | into string)" }}
    $t if $t =~ "^list" => { $labels }
    _ => {error make { msg: "labels must be int or list<string>" } }
  }
}

# macsOS will always keep one Space per display.
def reset-spaces [] {
  log info "Resetting non-fullscreen Spaces."
  let spaces = yabai-spaces | group-by display
  for row in ($spaces | transpose display spaces) {
    let display = $row.display
    let $sid = $row.spaces | sort-by index | get id
    for i in ($sid | skip 1) {
      log info $"Destroy space id=($i)"
      let cspace = yabai-spaces | where id == $i
      log debug $"space[($i)] native-fullscreen ($cspace | get is-native-fullscreen | last)"
      if ($cspace | get is-native-fullscreen | last) == false {
        log debug $"Destory space id=[($i)] success"
        ^yabai -m space --destroy ($cspace | get index | last)
      }
    }
  }
}


# smart ensure logic
# non-destructive fill based on existing space layout
# Also removes duplicate space labels beforehand
def clear-space-labels [] {
  log info "Clear space labels."
  let spaces = yabai-spaces | where label != ""
  if ($spaces | is-not-empty ) {
    $spaces | sort-by index -r | each { |s|
      log debug $"clear lable space index=($s.index)"
      ^yabai -m space $s.index --label ""
    }
  }
}

# creat and set label on space
def ensure-spaces [labels: list<any>] {
  log info "Ensuring Spaces layout."

  let displays = yabai-displays
  let display_count = $displays | length

  let total_labels = $labels | length
  # 计算需要补齐缺失的 spaces
  for d_idx in 0..($display_count - 1) {
    let display = $displays | get $d_idx
    let did = $display.index
    # 计算当前显示器预期需要的 space
    let expected_count = ($total_labels / $display_count | into int) + (if $d_idx < ($total_labels mod $display_count) { 1 } else { 0 })
     # 获取当前该显示器已有的非全屏空间数量
    let actual_count = (yabai-spaces | where display == $did and is-native-fullscreen == false | length)
    if $actual_count < $expected_count {
      let diff = $expected_count - $actual_count
      log info $"Display ($did) need ($diff) more space\(s\). Creating..."
      for i in 1..$diff {
        ^yabai -m space --create $did
      }
    }
  }
  # --- 第二阶段：绑定 Label ---
  # 此时空间已经全部创建完毕，重新获取最新的空间列表进行索引绑定
  let updated_spaces = yabai-spaces | where is-native-fullscreen == false

  for item in ($labels | enumerate) {
    mut label = null
    mut layout = null
    match ($item.item | describe) {
      "string" => { $label =  $item.item }
      $t if $t =~ "^list" => {
        $label = $item.item | first
        $layout = $item.item | last
      }
      $t if $t =~ "^record" => {
        $label = $item.item | get label
        $layout = $item.item | get layout
      }
    }

    let idx = $item.index

    let display = ($displays | get ($idx mod $display_count))
    let did = $display.index
    let required_index_on_display = ($idx // $display_count)

    # 从更新后的列表中精准提取目标
    let target = ($updated_spaces
                  | where display == $did
                  | sort-by index
                  | get $required_index_on_display)
    if ($layout == null) {
      log info $"Labeling space \(index: ($target.index)\) on display ($did) as '($label)'"
      ^yabai -m space $target.index --label $label
    } else {
      log info $"Labeling space \(index: ($target.index)\) on display ($did) as '($label)'"
      log info $"Layout space \(index: ($target.index)\) on display ($did) as '($layout)'"
      ^yabai -m space $target.index --label $label --layout $layout
    }
  }
}


# ---- core entry -----
def setup-spaces [labels: any, --force (-f)] {
  let labels = normalize-labels  $labels
  if $force {
    reset-spaces
  }
  clear-space-labels
  log info $"($labels | str join ',')"
  ensure-spaces $labels
}

# 配置 spaces, 不要强制使用 --force
setup-spaces ["main", "web", ["edit", "stack"], ["other", "float"]]

# 基于 space 的相关 rule 配置
yabai -m rule --add app='^(Arc|Google Chrome|Firefox|Zen Browser|LibreWolf)$' space=^web
yabai -m rule --add app='^(Ghostty|kitty|Iterm2|Wrap)' title='!FloatTerm' space=^edit
yabai -m rule --add app='^(AppClear|Activity Monitor|Telegram|Petrichor|bilibili-video-downloader)$' space=^other
yabai -m rule --add app='^(Zed|Visual Studio Code|IntelliJ IDEA|PyCharm|ChatGPT|Codex)$' space=^edit
