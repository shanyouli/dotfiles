;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(setq confirm-kill-processes nil) ; 退出后自动杀掉进程
;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Shanyou Li"
      user-mail-address "shanyouli6@gmail.com")

;; Doom exposes five (optional) variables or controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(defun my/font-installed-p (font-name)
  "Check if font with FONT-NAME is available."
  (if (find-font (font-spec :name font-name)) t nil))
(cl-loop for font in '("Cascadia Code" "JetBrains Mono" "Fantasque Sans Mono"
                       "Source Code Pro" "Menlo" "DejaVu Sans Mono" "monospace")
         when (my/font-installed-p font)
         return (setq doom-font (font-spec :family font :size 12)))
;; (setq doom-font (font-spec :family "Cascadia Code" :size 12))
;; use emoji color font
;; see @https://emacs-china.org/t/emacs-cairo/9437/13
(defun my/walle-ui-display-color-emoji? ()
  "Return non-nil if emacs can display color emoji.

Notice that this function assume you have graphics display"
  (or (and EMACS27+
           (featurep 'cairo)
           (let ((frame-font-backend
                  (frame-parameter (selected-frame) 'font-backend)))
             (when (or (memq 'ftcr frame-font-backend)
                       (memq 'ftcrhb frame-font-backend))
               t)))
      (featurep 'cocoa)))
(defadvice! my/use-color-emoji-a (&rest _)
  :after #'doom-init-extra-fonts-h
  (progn
    (when (my/walle-ui-display-color-emoji?)
      (cond (IS-MAC
             (set-fontset-font t 'symbol (font-spec :family "Apple Color Emoji")
                               nil 'prepend))
            (IS-LINUX
             (set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji")
                               nil 'prepend))))
    (cl-loop for font in '("zhHei" "Adobe Heiti Std" "STXihei"
                           "WenQuanYi Micro Hei Mono")
             when (my/font-installed-p font)
             return (set-fontset-font t '(#x4e00 . #x9fff)
                               (font-spec :family font)))))
;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-moonlight)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory (cond (IS-LINUX
                           (cl-some (lambda (dir)
                                      (if (file-directory-p dir)
                                          dir))
                                    (list
                                     "/data/Documents/Org"
                                     "~/Org"
                                     "~/org"
                                     "~/Documents/Org"
                                     )))))


(defun my/find-file-in-dotfiles ()
  "Browse your `DOTFILES'."
  (interactive)
  (let* ((dotfiles (or (getenv "DOTFILES")
                       (expand-file-name "~/.dotfiles"))))
    (unless (file-directory-p dotfiles)
      (make-directory dotfiles t))
    (doom-project-find-file dotfiles)))
;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; kill emacs, not prompt
(setq confirm-kill-emacs nil)
;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

;; Additional recentf package configuration

(setq recentf-max-saved-items 300
      recentf-exclude
      '("\\.?cache" ".cask" "url" "COMMIT_EDITMSG\\'" "bookmars"
        "\\.\\(?.gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
        "\\.?ido\\.last$" "\\.revive$" "/G?TAGS$" "/.elfeed/"
        "^/tmp/" "^/var/folders/.+$"
        (lambda (file)
          (or (file-directory-p file)
              (file-in-directory-p file package-user-dir)
              (and (bound-and-true-p straight-base-dir)
                   (file-in-directory-p
                    file
                    (concat straight-base-dir "straight")))
              (and (bound-and-true-p persp-save-dir)
                   (file-in-directory-p file persp-save-dir))
              (and (bound-and-true-p desktop-dirname)
                   (file-in-directory-p file desktop-dirname))))))
(after! org-roam
  (add-to-list 'org-roam-capture-ref-templates
               '("a" "Annotation" plain (function org-roam-capture--get-point)
                 "%U ${body}\n"
                 :file-name "${slug}"
                 :head "#+title: ${title}\n#+roam_key: ${ref}\n#+roam_alias:\n"
                 :immediate-finish t
                 :unnarrowed t)))

(after! org-superstar
  (setq org-superstar-headline-bullets-list '("◉" "○" "✸" "✿" "✤" "✜" "◆" "▶")
        ;; org-superstar-headline-bullets-list '("Ⅰ" "Ⅱ" "Ⅲ" "Ⅳ" "Ⅴ" "Ⅵ" "Ⅶ" "Ⅷ" "Ⅸ" "Ⅹ")
        org-superstar-prettify-item-bullets t ))
(after! org
  (setq org-ellipsis "▼"
        org-priority-highest ?A
        org-priority-lowest ?E
        org-priority-faces
        '((?A . 'all-the-icons-red)
          (?B . 'all-the-icons-orange)
          (?C . 'all-the-icons-yellow)
          (?D . 'all-the-icons-green)
          (?E . 'all-the-icons-blue))))
(after! recentf
  (push (expand-file-name recentf-save-file) recentf-exclude))

(after! all-the-icons
  (push '("\\.ass\\'" all-the-icons-material "subtitles"
          :face all-the-icons-yellow)
        all-the-icons-icon-alist))

(use-package! all-the-icons-ivy-rich
  :if (and (featurep! :completion ivy) (featurep! :emacs dired +icons))
  :hook (ivy-mode . all-the-icons-ivy-rich-mode))

(use-package! eaf
  :commands eaf-open
  :init
  (setq eaf-config-location (concat doom-local-dir "eaf/"))
  (setq eaf-proxy-type "http"
        eaf-proxy-host "127.0.0.1"
        eaf-proxy-port "1081")
  (setq eaf-find-alternate-file-in-dired t)
  :hook (eaf-mode . evil-emacs-state)
  :config
  ;; (eaf-setq eaf-browse-blank-page-url "https://duckduckgo.com")
  (setq eaf-browser-default-search-engine "duckduckgo"))


(when (featurep! :checkers syntax)
  (remove-hook 'doom-first-buffer-hook 'global-flycheck-mode)
  (add-hook 'sh-mode-hook 'flycheck-mode))

(use-package! rime
  :after-call after-find-file pre-command-hook
  :custom (default-input-method "rime")
  :init
  (setq rime-user-data-dir (concat doom-local-dir "rime/"))
  :config
  (unless rime-emacs-module-header-root
    (setq-default rime-emacs-module-header-root
                  (concat "/usr/include/" "emacs-"
                          (number-to-string emacs-major-version)
                          (if (eq emacs-minor-version 0)
                              "-vcs")
                          "/")))
  (when (and (display-graphic-p) (require 'posframe nil t))
    (setq rime-show-candidate 'posframe)
    ;;rime-posframe-style (list :background-color "#333333"
    ;;                        :foreground-color "#dcdccc"
    ;;                          :font "Sarasa Mono SC"
    ;;                          :internal-border-width 10))
    ;; (setq rime-disable-predicates
    ;;       '(rime-predicate-evil-mode-p
    ;;         rime-predicate-after-alphabet-char-p
    ;;         rime-predicate-prog-in-code-p))
    (setq rime-posfrmae-style 'horizontal)))

(use-package! sis
  ;; :after evil
  :hook (after-init . (lambda ()
                        ;; enable the /cursor color/ mode
                        (sis-global-cursor-color-mode t)
                        ;; enable the /respect/ mode
                        (sis-global-respect-mode t)
                        ;; enable the /follow context/ mode for all buffers
                        (sis-global-follow-context-mode t)
                        ;; enable the /inline english/ mode for all buffers
                        (sis-global-inline-mode t)))
  :config
  (push "M-<SPC>" sis-prefix-override-keys)
  (sis-ism-lazyman-config "1" "2"
                          (cond ((executable-find"fcitx5") 'fcitx5)
                                ((executable-find "fcitx") 'fcitx))))

(use-package! sdcv
  :commands lye-dict-search-at-point
  :init
  (setq sdcv-dictionary-data-dir (expand-file-name "sdcv"
                                                   (or (getenv "XDG_DATA_HOME")
                                                       "~/.local/share")))
  :config
  (setq sdcv-dictionary-simple-list ; setup dictionary list for simple search
        '("KDic11万英汉词典"
          "懒虫简明英汉词典"
          "懒虫简明汉英词典"))
  (setq sdcv-dictionary-complete-list ; setup dictionary list for complete search
        '("KDic11万英汉词典"
          "懒虫简明英汉词典"
          "懒虫简明汉英词典"
          "21世纪英汉汉英双向词典"
          "新世纪汉英科技大词典"
          "牛津现代英汉双解词典"
          "XDICT汉英辞典"
          "XDICT英汉辞典"
          "朗道汉英字典5.0"
          "朗道英汉字典5.0"
          "quick_eng-zh_CN"
          "CDICT5英汉辞典"))
  (defun lye-dict-search-at-point ()
    (interactive)
    (if (display-graphic-p)
        (call-interactively #'sdcv-search-pointer+)
      (call-interactively #'sdcv-search-pointer))))

(use-package! youdao-dictionary
  :commands lye-dict-search-at-point
  :init
  (setq youdao-dictionary-search-history-file ; Set file for saving search history
        (concat doom-local-dir "ydcv/"))
  :config
  (setq url-automatic-caching t
        ;; Enable Chinese word segmentation support (支持中文分词)
        youdao-dictionary-use-chinese-word-segmentaton t)
  (defun lye-dict-search-at-point ()
    (interactive)
    (if (display-graphic-p)
        (call-interactively #'youdao-dictionary-search-at-point-posframe)
      (call-interactively #'youdao-dictionary-search-at-point))))

(use-package! english-teacher
  :hook ((Info-mode
          elfeed-show-mode
          eww-mode
          Man-mode
          Woman-Mode) . english-teacher-follow-mode))

(use-package! super-save
  :hook (doom-first-file . super-save-mode)
  :config
  (push 'split-window-below super-save-triggers)
  (push 'split-window-right super-save-triggers)
  (push 'aw--select-window super-save-triggers)
  (push 'ace-window super-save-triggers))

(use-package! insert-translated-name
  :commands (insert-translated-name-insert-original-translation
             insert-translated-name-insert-with-underline
             insert-translated-name-insert-with-line
             insert-translated-name-insert-with-camel
             insert-translated-name-insert)
  :config
  (defvar int--evil-last-status-is-insert-p nil
      "Last evil-mode status is inserted?")
  (defvar int--sis-default-input-thmod nil
      "Staging the default input method.")
  (defun int/active-a (&rest _)
    (when (and (fboundp 'evil-insert-state-p) (evil-insert-state-p))
      (setq int--evil-last-status-is-insert-p t))
    (unless int--evil-last-status-is-insert-p
      (evil-insert-state))
    (when (boundp 'int--sis-default-input-thmod)
      (setq int--sis-default-input-thmod default-input-method)
      (setq-local default-input-method nil)
      (sis-set-other)))

  (defun int/inactive-a (&rest _)
    (unless int--evil-last-status-is-insert-p
      (evil-normal-state)
      (setq int--evil-last-status-is-insert-p nil))
    (when (bound-and-true-p int--sis-default-input-thmod)
      (sis-set-english)
      (setq-local default-input-method int--sis-default-input-thmod)
      (setq int--sis-default-input-thmod nil)))
  (advice-add #'insert-translated-name-active :before 'int/active-a)
  (advice-add #'insert-translated-name-inactive :after 'int/inactive-a))

(use-package! rainbow-mode
  :hook (prog-mode . rainbow-mode))

(use-package! css-mode
  :mode ("\\.rasi\\'" . css-mode))

(use-package! hungry-delete
  :hook (doom-first-buffer . global-hungry-delete-mode))

(when (executable-find "vterm-ctrl")
  (after! vterm
    (setq vterm-module-cmake-args "-DUSE_SYSTEM_LIBVTERM=yes")))

(defadvice! +no-query-kill-emacs-a (orign &rest args)
  "Prevent annoying \"Active process exits\" query when you quit Emacs."
  :around #'save-buffers-kill-emacs
  (require 'noflet)
  (noflet ((process-list ()))
          (apply orign args)))

(use-package! valign
  :commands valign-mode
  :hook ((org-mode markdown-mode)  . valign-mode)
  ;; :init
  ;; (setq valign-fancy-bar nil
  ;;       valign-separator-row-style 'multi-column)
  )

(use-package! sh-script
  :mode (("/.bashrc\\'" . sh-mode)))

(use-package! gif-screencast
  :commands gif-screencast-start-or-stop
  :config
  (setq gif-screencast-output-directory (expand-file-name "~/Videos/Gif")))

(use-package! org-roam-server
  :after org-roam
  :config
  (setq org-roam-server-host "127.0.0.1"
        org-roam-server-port 9091
        org-roam-server-export-inline-images t
        org-roam-server-authenticate nil
        org-roam-server-network-label-truncate t
        org-roam-server-network-label-truncate-length 60
        org-roam-server-network-label-wrap-length 20)
  (defun org-roam-server-open ()
    "Ensure the server is active, then open the roam graph."
    (interactive)
    (org-roam-server-mode 1)
    (browse-url-xdg-open (format "http://localhost:%d" org-roam-server-port))))

;;; Key
(map! :leader
      (:prefix-map ("e" . "eaf")
       (:when (fboundp 'eaf-open)
        :desc "Open a terimal" "t" #'eaf-open-terminal
        :desc "Open a file" "o" #'eaf-open
        :desc "Open a url" "l" #'eaf-open-url
        :desc "Search it" "s" #'eaf-search-it))
      (:when (fboundp 'lye-dict-search-at-point)
       :desc "Dictionary" "y" #'lye-dict-search-at-point)
      (:prefix-map ("i" . "insert")
       (:when (fboundp 'insert-translated-name-insert)
        :desc "Chinese to English" "t" #'insert-translated-name-insert-original-translation
        (:prefix-map ("T" . "ZH-EN format")
         :desc "underline" "u" #'insert-translated-name-insert-with-underline
         :desc "Original" "o" #'insert-translated-name-insert-original-translation
         :desc "line" "l" #'insert-translated-name-insert-with-line
         :desc "Camel" "c" #'insert-translated-name-insert-with-camel
         :desc "intelligent" "i" #'insert-translated-name-insert)))
      (:prefix-map ("u" . "user keys")
       (:when (fboundp 'gif-screencast-start-or-stop)
        :desc "gif screencast" "g" #'gif-screencast-start-or-stop)))
;; (map! "<XF86Tools>" 'toggle-input-method
;;       (:after rime
;;         :map rime-mode-map
;;         "C-`" #'rime-send-keybinding))

