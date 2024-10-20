#!/usr/bin/env nu

# 判断是否使用 rsync
def is-rsync-p [] {
  let os_system = sys host | get name
  let which_rsync = which rsync
  if ($which_rsync | is-empty) {
    false
  } else {
    ($os_system != "Darwin") or (not ($which_rsync | get --ignore-errors path | first | str starts-with "/usr/bin"))
  }
}

# rsync Realization of mv
export def rmv [ in_path: path, out_path: path ] {
  if (is-rsync-p) {
    ^rsync --archive --human-readable --progress --no-i-r --remove-source-files $in_path $out_path
    if (($in_path | path type) == "dir") and ((^find $in_path -type f | wc -l | into int) == 0) {
      # BUG: rm -rvf 1
      ^rm -rvf $in_path
    }
  } else {
    print $"{ansi yellow_b}rsync is not installed, please install it(ansi reset)"
    mv -vf $in_path $out_path
  }
  print $"(ansi green) move sourcess!!!(ansi reset)"
}

# rsync realization of cp
export def rcp [in_path: path, out_path: path ] {
  if (is-rsync-p) {
    ^rsync -ah --progress --no-i-r $in_path $out_path
  } else {
    cp -rv $in_path $out_path
  }
  print $"(ansi green) copy success!!!(ansi reset)"
}
