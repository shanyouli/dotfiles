{
  pkgs,
  lib,
  config,
  options,
  ...
}:
with lib;
with lib.my; let
  cfg = config.my.modules.macos.emacs;
  emacsPkg = config.my.modules.emacs.pkg;
  EmacsClientAppleScript = pkgs.writeScript "emacsclient" ''
    on emacsclient(input)
    	set cmd to "${emacsPkg}/bin/emacsclient"
    	-- set cmd to "/etc/profiles/per-user/lyeli/bin/emacsclient"
    	set base_cmd to ""
    	if runShellIsSuccess(cmd & " -s main --suppress-output --eval nil") then
    		set base_cmd to cmd & " -s main -n "
    	end if

    	if base_cmd is "" then
    		if runShellIsSuccess(cmd & " --suppress-output --eval nil") then
    			set base_cmd to cmd & " -n "
    		else
    			display notification "请运行 emacs --fg-daemon=main or Emacs 启动服务" with title "emacsDaemon 没有运行" subtitle "emacs"
    			my logit("OOPs: Emacs Daemon has not started", "Emacsclient")
    			return false
    		end if
    	end if
    	try
    		if input is "" then
    			set my_frames_is_t to do shell script base_cmd & "-e \"(fboundp '+my-emacs-client-open-frame)\""
    			if my_frames_is_t is "t" then
    				do shell script base_cmd & "--eval '(+my-emacs-client-open-frame)'"
    			else
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
          set my_frames_is_t to do shell script base_cmd & "-e \"(fboundp '+my-emacs-client-open-frame)\""
          if my_frames_is_t is "t" then
            do shell script base_cmd & " --eval '(+my-emacs-client-open-frame \"" & input & "\" )'"
          else
            do shell script base_cmd & "-c --frame-parameters='(quote (name . \"EmacsClient\"))' '" & input & "'"
          end if
    		end if
    	on error e number n
    		display notification e with title "Error" subtitle "emacs"
    		my logit("OOPs: " & e & " " & n, "Emacsclient")
    	end try
    end emacsclient

    to logit(log_string, log_file)
    	do shell script ¬
    		"echo `date '+%Y-%m-%d %T: '`\"" & log_string & "\" >> $HOME/Library/Logs/" & log_file & ".log"
    end logit

    on runShellIsSuccess(cmd)
    	try
    		do shell script cmd
    		return true
    	on error e number n
    		return false
    	end try
    end runShellIsSuccess

    on open location input
    	emacsclient(input)
    end open location

    on open inputs
    	repeat with raw_input in inputs
    		set input to POSIX path of raw_input
    		emacsclient(input)
    	end repeat
    end open

    on run
    	emacsclient("")
    end run
  '';
  infoPlist = builtins.toJSON [
    {
      CFBundleURLName = "org-protocol handler";
      CFBundleURLSchemes = ["org-protocol"];
    }
  ];
  icns = pkgs.stdenv.mkDerivation {
    name = "EmacsClient";
    src = pkgs.fetchurl {
      url = "https://github.com/nashamri/spacemacs-logo/raw/master/spacemacs.icns";
      sha256 = "sha256-s9uLfPpLxbziS8TcHt47dSxxhse1TAmZTqtexOqkiQA=";
    };
    unpackPhase = ''
      cp "$src" $(stripHash "$src")
    '';
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/EmacsClient
      cp -rv *.icns $out/share/EmacsClient/Emacsclient.icns
    '';
  };
  emacsClient = pkgs.stdenv.mkDerivation rec {
    name = "EmacsClient";
    version = emacsPkg.emacs.version;
    src = EmacsClientAppleScript;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/Applications
      /usr/bin/osacompile -o EmacsClient.app ${EmacsClientAppleScript}

      /usr/bin/plutil -insert CFBundleDisplayName -string "EmacsClient" EmacsClient.app/Contents/Info.plist

      # icons file
      /usr/bin/plutil -replace CFBundleIconFile -string "EmacsClient" EmacsClient.app/Contents/Info.plist
      # bundleID
      /usr/bin/plutil -insert CFBundleIdentifier -string "org.nixos.EmacsClient" EmacsClient.app/Contents/Info.plist

      # 版本号相关的
      /usr/bin/plutil -insert CFBundleShortVersionString -string "${version}" EmacsClient.app/Contents/Info.plist
      /usr/bin/plutil -insert CFBundleVersion -string "${version}" EmacsClient.app/Contents/Info.plist
      /usr/bin/plutil -insert CFBundleURLTypes -json ${
        lib.escapeShellArg infoPlist
      } EmacsClient.app/Contents/Info.plist
      cp -r ${icns}/share/EmacsClient/EmacsClient.icns EmacsClient.app/Contents/Resources/
      cp -r EmacsClient.app $out/Applications

    '';
  };
in {
  options.my.modules.macos.emacs = {
    enable = mkBoolOpt false;
    serverEnable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      my.modules.emacs = {
        enable = true;
        package = let
          # Fix OS window role (needed for window managers like yabai)
          role-patch = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/cmacrae/emacs/b2d582f/patches/fix-window-role.patch";
            sha256 = "0c41rgpi19vr9ai740g09lka3nkjk48ppqyqdnncjrkfgvm2710z";
          };
          basePackage = pkgs.emacs-unstable.override {
            # 使用 emacs-unstable 取代 emacs-git
            # webkitgtk-2.40.2+abi=4.0 is blorken,
            # @see https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/libraries/webkitgtk/default.nix
            # withXwidgets = true;
            # withGTK3 = true;
            withImageMagick = true; # org-mode 控制图片大小
            # @see https://emacs-china.org/t/native-compilation/23316/73
            # 目前没有任何提升
            withNativeCompilation = false;
          };
        in
          basePackage.overrideAttrs (old: {
            patches =
              (old.patches or [])
              ++ [
                role-patch
                # Use poll instead of select to get file descriptors
                (pkgs.fetchpatch {
                  url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/23c993b/patches/emacs-29/poll.patch";
                  sha256 = "sha256-jN9MlD8/ZrnLuP2/HUXXEVVd6A+aRZNYFdZF8ReJGfY=";
                })
                # Enable rounded window with no decoration
                (pkgs.fetchpatch {
                  url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/c281504/patches/emacs-29/round-undecorated-frame.patch";
                  sha256 = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
                  # url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/e98ed09/patches/emacs-30/round-undecorated-frame.patch";
                  # sha256 = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
                })
                # Make Emacs aware of OS-level light/dark mode
                (pkgs.fetchpatch {
                  url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/f3c16d6/patches/emacs-28/system-appearance.patch";
                  sha256 = "sha256-oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=";
                })
              ];
            buildInputs =
              old.buildInputs
              ++ [pkgs.darwin.apple_sdk.frameworks.WebKit];
            CFLAGS = "-DMAC_OS_X_VERSION_MAX_ALLOWED=110203 -g -O2";
            # src = inputs.emacs-src;
            # version = inputs.emacs-src.shortRev;
          });
        # doom.confInit = let
        #   postFix =
        #     lib.optionalString
        #     (builtins.isString config.my.modules.emacs.package.postFixup)
        #     config.my.modules.emacs.package.postFixup;
        #   postFixList =
        #     lib.splitString " "
        #     (builtins.replaceStrings ["\n"] [" "] postFix);
        #   fn = attr:
        #     builtins.filter (n:
        #       (lib.strings.hasPrefix "/nix/store" n)
        #       && (lib.strings.hasSuffix "tree-sitter-grammars/lib" n))
        #     attr;
        #   resultList = fn postFixList;
        # in
        #   lib.optionalString (resultList != []) ''
        #     (setq treesit-extra-load-path (list "${builtins.head resultList}"))
        #   '';
      };
    }
    (mkIf cfg.serverEnable {
      launchd.user.agents.emacs = {
        script = ''
          ${emacsPkg}/Applications/Emacs.app/Contents/MacOS/Emacs --fg-daemon=main
        '';
        serviceConfig.KeepAlive = true;
        serviceConfig.RunAtLoad = true;
        serviceConfig.EnvironmentVariables = {
          PATH = "${emacsPkg}/bin:${config.environment.systemPath}";
        };
      };
    })
    {
      my.user.packages = let
        # Pasting images to Emacs on macOS.
        pngpaste = with pkgs;
          stdenv.mkDerivation rec {
            src = fetchFromGitHub {
              owner = "jcsalterego";
              repo = "pngpaste";
              rev = "67c39829fedb97397b691617f10a68af75cf0867";
              sha256 = "089rqjk7khphs011hz3f355c7z6rjd4ydb4qfygmb4x54z2s7xms";
            };
            name = "pngpaste";
            buildInputs = [pkgs.darwin.apple_sdk.frameworks.Cocoa];
            installPhase = ''
              mkdir -p $out/bin
              cp pngpaste $out/bin/
            '';
          };
      in [pngpaste emacsClient];
      my.modules.zsh.rcInit = ''
        alias emacs="${emacsPkg}/Applications/Emacs.app/Contents/MacOS/Emacs"
      '';
    }
  ]);
}
