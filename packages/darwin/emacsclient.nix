{
  lib,
  runCommandLocal,
  stdenv,
  writeText,
  terminal-notifier,
  emacsClientBin ? "/usr/bin/emacsclient",
  withNotify ? false,
  source,
  ...
}: let
  messageCmd =
    if withNotify
    then "${terminal-notifier}/bin/terminal-notifier"
    else "";
  EmacsClientAppleScript = writeText "emacsclient" ''
    on emacsclient(input)
      set cmd to "${emacsClientBin}"
      -- set cmd to "/etc/profiles/per-user/lyeli/bin/emacsclient"
      set messageCmd to "${messageCmd}"

      set daemonFile to getDaemon(cmd)
      if daemonFile is "" then
        sendNotify(messageCmd, "EmacsClient", "emacsDaemon 没有运行", "请运行 emacs --fg-daemon=main or Emacs 启动服务")
        my logit("OOPs: Emacs Daemon has not started", "Emacsclient")
        return false
      end if
      set base_cmd to cmd & " -s " & daemonFile & " -n "
      try
        if input is "" then
          if not runMyFunction(base_cmd, "+my-emacs-client-open-frame") then
            set visible_frames to do shell script base_cmd & "-e '(length (visible-frame-list))'"
            set vf to visible_frames as number
            if vf = 1 then
              do shell script base_cmd & "-c --frame-parameters='(quote (name . \"EmacsClient\"))' --eval '(switch-to-buffer \"*scratch*\")'"
            end if
            do shell script base_cmd & "-e '(select-frame-set-input-focus (selected-frame))'"
          end if
        else if input starts with "org-protocol://" then
          do shell script base_cmd & "'" & input & "'"
        else
          do shell script base_cmd & "-c --frame-parameters='(quote (name . \"EmacsClient\"))' '" & input & "'"
        end if
      on error e number n
        sendNotify(messageCmd, "EmacsClient Error", "", e)
        my logit("OOPs: " & e & " " & n, "Emacsclient")
      end try
    end emacsclient

    to logit(log_string, log_file)
      do shell script ¬
        "echo `date '+%Y-%m-%d %T: '`\"" & log_string & "\" >> $HOME/Library/Logs/" & log_file & ".log"
    end logit

    on open location input
      emacsclient(input)
    end open location

    on open inputs
      repeat with raw_input in inputs
        set input to POSIX path of raw_input
        emacsclient(input)
      end repeat
    end open

    on getDaemon(cmd)
      set server_list to {"main", "server"}
      repeat with citem in server_list
        set daemonFile to do shell script "lsof -c Emacs | grep " & citem & " | tr -s \" \" | cut -d' ' -f8 | head -n1"
        if daemonFile is not equal to "" then
          return daemonFile
        end if
      end repeat
      return ""
    end getDaemon

    on sendNotify(cmd, titleText, subtitleText, messageText)
      if cmd is "" then
        if titleText is "" then
          set titleText to "EmacsClient"
        end if
        if subtitleText is "" then
          set subtitleText to "EmacsClient"
        end if
        display notification messageText with title titleText subtitle subtitleText
      else
        set cmd to cmd & " -message \"" & messageText & "\""
        if titleText is not equal to "" then
          set cmd to cmd & " -title \"" & titleText & "\""
        end if
        if subtitleText is not equal to "" then
          set cmd to cmd & " -subtitle \"" & subtitleText & "\""
        end if
        do shell script cmd
      end if
    end sendNotify

    on runMyFunction(cmd, func)
      try
        set result to do shell script cmd & " --eval \"(fboundp '" & func & ")\""
        if result is "t" then
          set result to do shell script cmd & " --eval \"(" & func & ")\""
          if result is "t" then
            return true
          end if
        end if
        return false
      on error e number n
        my logit("OOPs: " & e & " " & n, "Emacsclient")
        return false
      end try
    end runMyFunction

    on run
      emacsclient("")
    end run
  '';
  icns = source.src;
  infoPlist = builtins.toJSON [
    {
      CFBundleURLName = "org-protocol handler";
      CFBundleURLSchemes = ["org-protocol"];
    }
  ];

  buildEnv = runCommandLocal "build-symlinks" {} ''
    mkdir -p $out/bin
    ln -s /usr/bin/{osacompile,plutil} $out/bin
  '';
in
  stdenv.mkDerivation rec {
    pname = "EmacsClient";
    version = "29.2";
    srcs = [EmacsClientAppleScript icns];
    phases = ["installPhase"];
    buildInputs = [buildEnv];
    installPhase = ''
      mkdir -p $out/Applications
      osacompile -o EmacsClient.app ${EmacsClientAppleScript}

      plutil -insert CFBundleDisplayName -string "EmacsClient" EmacsClient.app/Contents/Info.plist

      # icons file
      plutil -replace CFBundleIconFile -string "EmacsClient" EmacsClient.app/Contents/Info.plist

      # execute
      plutil -replace CFBundleExecutable -string "EmacsClient" EmacsClient.app/Contents/Info.plist

      # bundleID
      plutil -insert CFBundleIdentifier -string "org.nixos.EmacsClient" EmacsClient.app/Contents/Info.plist

      # 版本号相关的
      plutil -insert CFBundleShortVersionString -string "${version}" EmacsClient.app/Contents/Info.plist
      plutil -insert CFBundleVersion -string "${version}" EmacsClient.app/Contents/Info.plist
      plutil -insert CFBundleURLTypes -json ${
        lib.escapeShellArg infoPlist
      } EmacsClient.app/Contents/Info.plist

      cp -R ${icns} EmacsClient.app/Contents/Resources/EmacsClient.icns
      rm -rf EmacsClient.app/Contents/Resources/droplet.icns
      mv -f EmacsClient.app/Contents/MacOS/droplet EmacsClient.app/Contents/MacOS/EmacsClient
      cp -R EmacsClient.app $out/Applications
    '';
  }
