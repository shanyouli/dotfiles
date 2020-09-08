;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here, run 'doom sync' on
;; the command line, then restart Emacs for the changes to take effect.
;; Alternatively, use M-x doom/reload.
;;
;; WARNING: Disabling core packages listed in ~/.emacs.d/core/packages.el may
;; have nasty side-effects and is not recommended.


;; All of Doom's packages are pinned to a specific commit, and updated from
;; release to release. To un-pin all packages and live on the edge, do:
;(unpin! t)

;; ...but to unpin a single package:
;(unpin! pinned-package)
;; Use it to unpin multiple packages
;(unpin! pinned-package another-pinned-package)


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;(package! some-package)

;; To install a package directly from a particular repo, you'll need to specify
;; a `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/raxod502/straight.el#the-recipe-format
;(package! another-package
;  :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;(package! this-package
;  :recipe (:host github :repo "username/repo"
;           :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, for whatever reason,
;; you can do so here with the `:disable' property:
;(package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;(package! builtin-package :recipe (:nonrecursive t))
;(package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see raxod502/straight.el#279)
;(package! builtin-package :recipe (:branch "develop"))

(package! eaf :recipe (:type git :host github
                             :repo "manateelazycat/emacs-application-framework"
                             :files ("app" "core" "*.el" "*.py")
                             :no-byte-compile t))
;; chinese input-method
(package! rime)
(package! rainbow-mode)
(package! ebuild-mode :ignore (not (executable-find "emerge")))

(if (executable-find "sdcv")
    (package! sdcv :recipe (:type git :host github
                                  :repo "manateelazycat/sdcv"))
  (package! youdao-dictionary))

(package! super-save :recipe (:type git :host github
                                    :repo "shanyouli/super-save"))

(package! insert-translated-name
  :recipe (:type git
                 :host github
                 :repo "manateelazycat/insert-translated-name"))
(package! snails :recipe (:type git :host github
                                :repo "manateelazycat/snails"
                                :no-byte-compile t))

(package! noflet)
(package! lazycat-theme :recipe (:type git
                                       :host github
                                       :repo "shanyouli/lazycat-theme"))

(package! valign :recipe (:type git
                          :host github
                          :repo "casouri/valign"))
(package! english-teacher :recipe (:type git
                                   :host github
                                   :repo "loyalpartner/english-teacher.el"
                                   :no-byte-compile t))
(package! sis :recipe (:type git
                        :host github
                        :repo "laishulu/emacs-smart-input-source"))

(package! hungry-delete)

(package! iedit)

(package! all-the-icons-ivy-rich)

(if (and (or (executable-find "scrot")
             (executable-find "screencapture"))
         (executable-find "convert") ;; imagemagick
         (executable-find "gifsicle"))
    (package! gif-screencast)
  (disable-packages! gif-screencast))

;; (or (getenv "XDG_VIDEOS_DIR")
;;     (xdg-user-dir "VIDEOS")
;;     (expand-file-name "Videos/emacs/" "~"))

(package! org-roam-server)
(unless (executable-find "nixos-install")
  (disable-packages! company-nixos-options))

(unpin! doom-modeline)
(disable-packages! pyim pangu-spaceing fcitx)
