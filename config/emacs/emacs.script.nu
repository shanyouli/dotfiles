#!/usr/bin/env nu


module doom {
  def get_path [] {
    if (($env.PATH | describe) == "string")  {
       $env.PATH | split row (char esep)
                 | path expand --no-symlink
                 | filter {|x| (not ($x | str starts-with "/nix/store"))}
                 | str join (char esep)
    } else {
       $env.PATH | path expand --no-symlink
                 | filter {|x| (not ($x | str starts-with "/nix/store"))}
                 | str join (char esep)
    }
  }

  # (Re)generates envvars file from your shell environment.
  export def --wrapped "env" [ ...rest] {
    let get_my_path = get_path
    with-env { PATH: $get_my_path } {
      if ($rest | is-empty) {
        ^doom env -d "EMACSLOADPATH" -d "EMACSNATIVELOADPATH" -d "emacsWithPackages_site.*"
      } else {
        ^doom env ...$rest
      }
    }
  }

  # command line interface to Doom Emacs
  export def --wrapped main [...rest] {
    if ($rest | is-empty) {
      ^doom help
      return 0
    }
    let subcmd = $rest | first
    if ($subcmd == "sync") {
      if ($rest | any {|x| $x == "-e"}) {
        ^doom ...$rest
      } else {
        let rest = $rest | insert 1 "-e"
        ^doom ...$rest
        env
      }
    } else if (["install", "upgrade"] | any {|x| $x == $subcmd}) {
      ^doom ...$rest
      env
    } else {
      ^doom ...$rest
    }
  }

}

export def emacsclient [...rest] {
  mut base_name = "emacs"
  if ((sys host | get name) == "Darwin") {
    $base_name = "Emacs"
  }
  mut sock_file = (lsof -c $base_name | grep main | tr -s " " | cut -d' ' -f8)
  if ($sock_file | is-empty) {
    $sock_file = (lsof -c $base_name | grep server | tr -s " " | cut -d' ' -f8)
  }
  if ($sock_file | is-empty) {
    ^emacsclient ...$rest
  } else {
    ^emacsclient -s $sock_file ...$rest
  }
}
export alias ec = emacsclient
export alias ecn = emacsclient -nw -n
export alias ecc = emacsclient -n -c

export use doom
