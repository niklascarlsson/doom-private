;;; +eshell.el -*- lexical-binding: t; -*-

(after! eshell
  ;; enable sudo
  (require 'em-tramp)
  (setq eshell-prefer-lisp-functions t
        eshell-prefer-lisp-variables t)

  ;; customize variables
  (setq eshell-hist-ignoredups t
        eshell-buffer-maximum-lines 1024
        eshell-history-size 10000)

  ;; Visual commands require a proper terminal. Eshell can't handle that, so
  ;; it delegates these commands to a term buffer.
  (after! em-term
    (pushnew! eshell-visual-commands "bluetoothctl"))

  ;;
  ;; Keybindings
  ;; Keys must be bound in a hook because eshell resets its keymap every
  ;; time `eshell-mode' is enabled.
  (add-hook! 'eshell-first-time-mode-hook
    (defun nc/+eshell-init-keymap-h ()
      (map!
       :map eshell-mode-map
       :i "C-p" 'eshell-previous-input
       :i "C-n" 'eshell-next-input
       :i "M-c" 'counsel-projectile-find-dir
       :i "C-k" #'evil-window-up
       :i "C-j" #'evil-window-down
       :i "C-h" #'evil-window-left
       :i "C-l" #'evil-window-right
       )))


  ;;
  ;; Aliases
  (set-eshell-alias!
   "ff" "+ivy/projectile-find-file"
   "/p" "+ivy/project-search"
   "/d" "+ivy/project-search-from-cwd"
   "d" "deer $1"
   "l" "ls -l"
   "la" "ls -la"
   "gl" "(call-interactively 'magit-log-current)"
   "gs" "magit-status"
   "gc" "magit-commit"
   "gbD" "nc/git-branch-delete-regexp $1"
   "gbS" "nc/git-branch-match $1"
   "rg" "rg --color=always $*"
   "bat" "nc/eshell-bat $1"
   "sudo" "eshell/sudo $*"
   "nm" "nc/enwc"
   "locate" "counsel-locate $1")
  (setenv "PAGER" "cat"))


;;
;; Detach
(use-package! eshell-detach
  :after eshell
  :config
  (setq eshell-detach-max-file-name-length 60)
  (add-hook! 'eshell-first-time-mode-hook
    (defun eshell-detach-init-keymap-h ()
      (map! :map eshell-mode-map
            :ni [C-return] #'eshell-detach-attach
            :ni [S-return] #'eshell-detach-send-input))))


;;
;; Auto-suggestion
(use-package! esh-autosuggest
  :after eshell
  :config
  (add-hook 'eshell-mode-hook #'esh-autosuggest-mode)
  (when (and (executable-find "fish")
             (require 'fish-completion nil t))
    (global-fish-completion-mode)))
