;; Mac specific setup
(when IS-MAC
  (setq ns-use-thin-smoothing t)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
               mac-option-modifier 'alt
               mac-command-modifier 'meta
	)


;; Arch setup
(if (string-match "ARCH"
         (with-temp-buffer (shell-command "uname -r" t)
                           (goto-char (point-max))
                           (delete-char -1)
                           (buffer-string)))
    (setq x-super-keysym 'meta
      x-alt-keysym 'alt))


;; General setup
(setq user-full-name    "Niklas Carlsson"
      user-mail-address "carlsson.niklas@gmail.com"

      +doom-modeline-buffer-file-name-style 'relative-from-project
      show-trailing-whitespace t
      ;; Don't ask when killing emacs
      confirm-kill-emacs nil
      )
;; tabs
;; Python try to guess tab-width but it assumes wrong width sometimes, turn it
;; off to make it more consistent. I always want 4 spaces for my tabs.
(setq python-indent-guess-indent-offset nil)
;; maximize first frame
(set-frame-parameter nil 'fullscreen 'maximized)
;; remove trailing whitespaces (globaly)
(add-hook 'before-save-hook #'delete-trailing-whitespace)


;; Load custom functions
(load! "+functions")


;; Unimpaired functions
(defun evil-unimpaired/insert-space-above (count)
  (interactive "p")
  (dotimes (_ count) (save-excursion (evil-insert-newline-above))))
(defun evil-unimpaired/insert-space-below (count)
  (interactive "p")
  (dotimes (_ count) (save-excursion (evil-insert-newline-below))))


;; Writeroom
(add-hook 'writeroom-mode-hook (lambda ()
                                 (progn
                                   (visual-line-mode 1)
                                   (hl-line-mode -1))))

;; TRAMP
;; make tramp assume ssh to avoid typing it when connecting to remote host
(setq tramp-default-method "ssh")


;; Ediff
(add-hook 'ediff-prepare-buffer-hook #'outline-show-all)


;; Flyspell
;; this should be set to nil for performance
;; https://www.emacswiki.org/emacs/FlySpell
(setq flyspell-issue-message-flag nil)


;; Flycheck
;; disable using hooks
(add-hook 'text-mode-hook (lambda ()
                            (flycheck-mode -1)))
(add-hook 'org-mode-hook (lambda ()
                           (flycheck-mode -1)))


;; Elisp
;; prettify lambdas in elisp
(add-hook 'emacs-lisp-mode-hook #'prettify-symbols-mode)
;; Let the scratch buffer have elisp major mode by default
;; if set to t it has the same mode as previous buffer
(setq doom-scratch-buffer-major-mode 'emacs-lisp-mode)


;; Lispy(ville)
;; enable lispy in emacs-lisp mode
(add-hook 'emacs-lisp-mode-hook (lambda () (lispy-mode 1)))
;; enable lispy in eval expression as well M-;
(defun conditionally-enable-lispy ()
  (when (eq this-command 'eval-expression)
    (lispy-mode 1)))
(add-hook 'minibuffer-setup-hook 'conditionally-enable-lispy)
;; enable lispyville wherever lispy is enabled
(add-hook 'lispy-mode-hook #'lispyville-mode)
;; key themes
(with-eval-after-load 'lispyville
  (lispyville-set-key-theme
   '(operators
     c-w
     ;; prettify
     (escape insert)
     text-objects
     (additional-insert insert)
     (additional-movement normal visual motion)
     additional
     atom-motions
     (slurp/barf-cp))))
;; Questions: Difference barf-lispy vs barf-cp

;; Docker-Tramp
(require 'docker-tramp)


;; Org-mode
;; customize org-settings
(after! org
  (setq outline-blank-line nil)
  (setq org-cycle-separator-lines 2)
  (setq org-log-done 'time))
;; Turn of highlight line in org-mode
(add-hook 'org-mode-hook (lambda ()
                           (hl-line-mode -1)))
;; automatically redisplay images generated by babel
(add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)
;; place latex-captions below figures and tables
(setq org-latex-caption-above nil)
;; Enable eshell in babel blocks
(load! "+eshell")
;; Helm-rifle
(require 'helm-org-rifle)

;; Agenda
;; specify the main org-directory
(setq org-directory "~/org")
;; set which directories agenda should look for todos
(setq org-agenda-files '("~/Dropbox/org"
                         "~/org"
                         "~/org/brain"
                         "~/org/work"))
;; synchronize gcal
(add-hook 'org-agenda-mode-hook (lambda () (org-gcal-sync) ))
(add-hook 'org-capture-after-finalize-hook (lambda () (org-gcal-sync) ))


;; Org-(super)-agenda
(def-package! org-super-agenda
  :after org-agenda
  :init (advice-add #'org-super-agenda-mode :around #'doom*shut-up)
  :config (org-super-agenda-mode)
  )
(after! org-agenda
  ;; New stuff
  (load! "+cool-agenda.el")

  (advice-add #'org-agenda-todo :after #'(lambda (&optional arg)
                                           (save-some-buffers t (lambda () (string= buffer-file-name (car org-agenda-contributing-files))))
                                           (org-agenda-redo)
                                           ))
  (advice-add #'org-agenda-redo :around #'doom*shut-up)
  ;; (advice-add #'org-agenda-refile :after #'aj/take-care-of-org-buffers)
  ;; (advice-add #'org-agenda-exit :after #'aj/take-care-of-org-buffers)
  ;; (advice-add #'aj/org-agenda-refile-to-file :after #'aj/take-care-of-org-buffers)
  ;; (advice-add #'aj/org-agenda-refile-to-datetree :after #'aj/take-care-of-org-buffers)
  ;; (advice-add #'aj/org-agenda-refile-to-project-readme :after #'aj/take-care-of-org-buffers)
  (advice-add 'org-agenda-change-all-lines :before '+agenda*change-all-lines-fixface)
  (advice-add 'org-agenda-archive :after #'org-save-all-org-buffers)
  (advice-add 'org-agenda-archive-default :after #'org-save-all-org-buffers)
  (advice-add 'org-agenda-exit :before 'org-save-all-org-buffers)
  (advice-add 'org-agenda-switch-to :after 'turn-off-solaire-mode)
  ;; (advice-add #'org-copy :after #'aj/take-care-of-org-buffers)
  (add-hook 'org-agenda-mode-hook #'hide-mode-line-mode)
  ;; (add-hook 'org-agenda-mode-hook #'aj/complete-all-tags-for-org)
  (add-hook 'org-agenda-after-show-hook 'org-narrow-to-subtree)
  (add-hook 'org-agenda-finalize-hook '(lambda ()
                                         (setq-local org-global-tags-completion-table
                                                     (org-global-tags-completion-table org-agenda-contributing-files))))
  ;; (add-hook 'org-after-todo-statistics-hook 'org-summary-todo)
  (remove-hook 'org-agenda-finalize-hook '+org|cleanup-agenda-files)

  (setq

   ;; org-agenda-files '("~/org/GTD.org")
   org-agenda-prefix-format '((agenda  . "  %-5t %6e ")
                              (timeline  . "%s ")
                              (todo  . " ")
                              (tags  . " ")
                              (search . "%l"))

   org-agenda-tags-column 68
   org-agenda-category-icon-alist
   `(("GTD" ,(list (all-the-icons-faicon "cogs")) nil nil :ascent center))
   org-agenda-todo-list-sublevels t
   org-agenda-log-mode-items '(closed clock state)
   org-agenda-span 7
   org-agenda-start-on-weekday 1
   org-agenda-start-with-log-mode nil
   org-agenda-start-day "1d"
   org-agenda-compact-blocks t
   org-agenda-dim-blocked-tasks t
   org-agenda-use-time-grid nil
   org-agenda-time-grid '((daily today require-timed) nil " " " ")

   org-agenda-custom-commands
   ' (

      ("R" "Current scheduled"
       (

        (agenda ""
                ((org-agenda-overriding-header "")
                 (org-agenda-show-current-time-in-grid t)
                 (org-agenda-use-time-grid t)
                 (org-agenda-skip-scheduled-if-done t)
                 (org-agenda-span 'day)
                 ))
        )
       (

        (org-agenda-prefix-format '((agenda  . "  %-5t %6e ")
                                    (timeline  . "%s ")
                                    (todo  . " ")
                                    (tags  . " ")
                                    (search . "%l")))
        )
       )



      ("c" "Clever"
       (

        (agenda ""
                ((org-agenda-overriding-header "")
                 (org-agenda-show-current-time-in-grid t)
                 (org-agenda-use-time-grid t)
                 (org-agenda-skip-scheduled-if-done nil)
                 (org-agenda-span 'day)
                 ))
        (+agenda-tasks)
        )
       (
        (org-agenda-skip-deadline-prewarning-if-scheduled 'pre-scheduled)
        (org-agenda-tags-todo-honor-ignore-options t)
        (org-agenda-todo-ignore-scheduled 'all)
        (org-agenda-todo-ignore-deadlines 'far)
        (org-agenda-skip-scheduled-if-done t)
        (org-agenda-start-with-log-mode t)
        (org-agenda-skip-deadline-if-done t)
        (org-agenda-skip-scheduled-if-deadline-is-shown t)
        (org-agenda-clockreport-parameter-plist `(:link t :maxlevel 6 :fileskip0 t :compact t :narrow 100))
        (org-agenda-columns-add-appointments-to-effort-sum t)
        (org-agenda-dim-blocked-tasks nil)
        (org-agenda-todo-list-sublevels nil)
        (org-agenda-block-separator "")
        (org-agenda-time-grid '((daily today require-timed) nil " " " "))
        )
       )

      ("i" "Inbox" ((tags "CALENDAR|INBOX"
                          ((org-super-agenda-groups
                            '((:discard (:tag "exclude"))
                              (:name none
                                     :and (:tag "CALENDAR" :scheduled today)
                                     :tag "INBOX")
                              (:discard (:anything t)))))))
       ((org-agenda-overriding-header " Inbox")
        (org-agenda-hide-tags-regexp  "INBOX\\|CALENDAR\\|tags3")
        (org-tags-match-list-sublevels t)))

      ("T" "Tasks" ((tags-todo "*"))((org-agenda-overriding-header "Tasks (no children, no schedule, by file)")
                                     (org-agenda-prefix-format '((agenda  . "  %-5t %6e ")
                                                                 (timeline  . "%s ")
                                                                 (todo  . " ")
                                                                 (tags  . " ")
                                                                 (search . "%l")))
                                     (org-tags-match-list-sublevels t)
                                     (org-super-agenda-groups
                                      '((:discard (:children t))
                                        (:discard (:scheduled t))
                                        (:name "Projects"
                                               :auto-category t
                                               )))))
      ("3" "Someday" ((tags "+LEVEL=1"))
       ((org-agenda-overriding-header "Someday...")
        (org-agenda-files `(,+SOMEDAY))
        (org-agenda-prefix-format '((agenda  . "  %-5t %6e ")
                                    (timeline  . "%s ")
                                    (todo  . " ")
                                    (tags  . " ")
                                    (search . "%l")))
        ))

      ("9" "Calendar" ((agenda "*"))
       ((org-agenda-files `(,+GTD))
        (org-tags-match-list-sublevels t)
        (org-agenda-skip-entry-if 'todo)
        (org-agenda-hide-tags-regexp "CALENDAR")
        (org-agenda-skip-scheduled-if-done t)
        ))

      ("8" "Maybe" ((tags "*"))
       ((org-agenda-overriding-header "Maybe...")
        (org-agenda-files `(,+MAYBE))
        (org-agenda-prefix-format '((agenda  . "  %-5t %6e ")
                                    (timeline  . "%s ")
                                    (todo  . " ")
                                    (tags  . " ")
                                    (search . "%l")))
        (org-tags-match-list-sublevels t)
        ))

      ("P" "Projects" ((tags-todo "*"
                                  ((org-agenda-overriding-header "Projects")
                                   (org-super-agenda-groups
                                    '(
                                      (:name "Action"
                                             :children "NEXT")

                                      (:name "Stucked:"
                                             :and (:children t :todo "STARTED")
                                             :and (:children nil :todo "STARTED"))
                                      (:name "By children"
                                             :children t)
                                      (:discard (:anything t))
                                      )))
                                  ))
       ((org-agenda-prefix-format '((agenda  . "  %-5t %6e ")
                                    (timeline  . "%s ")
                                    (todo  . " ")
                                    (tags  . " ")
                                    (search . "%l")))
        (org-tags-match-list-sublevels t)
        ))

      ("p" "Projectile Projects" ((todo ""))
       ((org-agenda-files `,(get-all-projectile-README-org-files))
        (org-agenda-overriding-header "All Projectile projects")
        (org-super-agenda-groups
         '((:name "Projects"
                  :auto-group t)))))

      )
   )
  )


;; Org-Noter
(def-package! org-noter
  :config
  (map!
   (:leader
     (:prefix "n"
       :desc "Org-noter-insert" :n "i" #'org-noter-insert-note))))
;; Setup
(setq org-noter-always-create-frame nil
      org-noter-auto-save-last-location t)


;; Org-brain
(use-package org-brain :ensure t
  :init
  ;; For Evil users
  (with-eval-after-load 'evil
    (evil-set-initial-state 'org-brain-visualize-mode 'emacs))
  :config
  (setq org-id-track-globally t)
  (setq org-id-locations-file "~/.emacs.d/.org-id-locations")
  (push '("b" "Brain" plain (function org-brain-goto-end)
          "* %i%?" :empty-lines 1)
        org-capture-templates)
  (setq org-brain-visualize-default-choices 'all)
  (setq org-brain-title-max-length 12))
;; Rifle the org-brain directory
(defun helm-org-rifle-brain ()
  "Rifle files in `org-brain-path'."
  (interactive)
  (helm-org-rifle-directories (list org-brain-path)))


;; Projectile
(setq projectile-enable-caching nil)


;; Hugo
(use-package ox-hugo
  :ensure t                      ;Auto-install the package from Melpa (optional)
  :after ox)
(use-package ox-hugo-auto-export) ;If you want the auto-exporting on file saves


;; Pop-rule
(after! org
  (set-popup-rule! "^\\*Org Agenda.*\\*$" :size 0.5 :side 'right :vslot 1  :select t :quit t   :ttl nil :modeline nil :autosave t)
  (set-popup-rule! "^CAPTURE.*\\.org$"    :size 0.4 :side 'bottom          :select t                                  :autosave t))


;; Magit
;; automatic spellchecking in commit messages
(add-hook 'git-commit-setup-hook 'git-commit-turn-on-flyspell)


;; Multi-Term
;; solve missing variables in terminal
(when IS-MAC
  (setenv "LC_CTYPE" "UTF-8")
  (setenv "LC_ALL" "en_US.UTF-8")
  (setenv "LANG" "en_US.UTF-8")
  )


;; Automatically switch back to English in normal mode
(cond (IS-LINUX
  (setq prev_lang (substring (shell-command-to-string
                              "gsettings get org.gnome.desktop.input-sources current")
                             7 -1))
  (add-hook 'evil-insert-state-entry-hook
            (lambda ()
              (shell-command (concat
                              "/usr/bin/gsettings set org.gnome.desktop.input-sources current " prev_lang))))

  (add-hook 'evil-insert-state-exit-hook
            (lambda ()
              (setq prev_lang (substring (shell-command-to-string
                                          "gsettings get org.gnome.desktop.input-sources current")
                                         7 -1))
              (shell-command (concat
                              "/usr/bin/gsettings set org.gnome.desktop.input-sources current 1"))))))


;; LSP-Mode
(def-package! lsp-mode
  :commands (lsp-mode))


;; LSP-Company
(def-package! company-lsp
  :after lsp-mode)
(set-company-backend! '(c-mode c++-mode) '(company-lsp company-files company-yasnippet))
(after! lsp-mode
  (setq company-lsp-enable-snippet t)
  (setq company-lsp-cache-candidates nil)
  (setq company-lsp-async t))


;; LSP-Flycheck
(require 'lsp-ui-flycheck)
(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-after-open-hook (lambda () (lsp-ui-flycheck-enable 1))))
(add-hook 'c-mode-common-hook 'flycheck-mode) ;; Turn on flycheck for C++ buffers


;; GDB
;; Disable realgud safe prompt after command
(setq realgud-safe-mode nil)
;; Open debugging window style
(setq gdb-many-windows t)


;; Fill column indication
;; turn it off by default
(remove-hook! (text-mode prog-mode conf-mode) #'turn-on-fci-mode)

;; eshell
;; add fish-like autocompletion
(def-package! esh-autosuggest)
(add-hook 'eshell-mode-hook #'esh-autosuggest-mode)
;; utilize completion from fish
(when (and (executable-find "fish")
           (require 'fish-completion nil t))
  (global-fish-completion-mode))
;; aliases
(after! eshell
  (set-eshell-alias!
   "ff"  "+helm/projectile-find-file"
   "fd"  "helm-projectile-find-dir"
   "/p" "+helm/project-search"
   "/d" "+helm/project-search-from-cwd"
   "l"   "ls -l"
   "la"  "ls -la"
   "d"   "dired $1"
   "gl"  "(call-interactively 'magit-log-current)"
   "gs"  "magit-status"
   "gc"  "magit-commit"
   "gbD" "my/git-branch-delete-regexp $1"
   "gbS" "my/git-branch-match $1"
   "rg"  "rg --color=always $*"))
;; Improvements from howard abrahams
;; programs that want to pause the output uses cat instead
(setenv "PAGER" "cat")


;; Dired
;; Make it possible to move files between two open Direds easily
(setq dired-dwim-target t)


;; ccls
(def-package! ccls
  :commands (lsp-ccls-enable)
  :init
  :config
  (setq ccls-executable (expand-file-name "~/opensource/ccls/Release/ccls")
        ccls-cache-dir (concat doom-cache-dir ".ccls_cached_index")
        ccls-sem-highlight-method 'font-lock)
  (setq ccls-extra-args '("--log-file=/tmp/cc.log"))
  (setq ccls-extra-init-params
        '(:completion (:detailedLabel t) :xref (:container t)
                      :diagnostics (:frequencyMs 5000)))
  (set-company-backend! '(c-mode c++-mode) '(company-lsp))
  )
;; run ccls by default in C++ files
(defun ccls//enable ()
  (condition-case nil
      (lsp-ccls-enable)
    (user-error nil)))
  (use-package ccls
    :commands lsp-ccls-enable
    :init (add-hook 'c-mode-common-hook #'ccls//enable))


;; org-caputre snippets
;; http://www.howardism.org/Technical/Emacs/capturing-content.html
(require 'which-func)

(defun my/org-capture-clip-snippet (f)
  "Given a file, F, this captures the currently selected text
within an Org EXAMPLE block and a backlink to the file."
  (with-current-buffer (find-buffer-visiting f)
    (my/org-capture-fileref-snippet f "EXAMPLE" "" nil)))

(defun my/org-capture-code-snippet (f)
  "Given a file, F, this captures the currently selected text
within an Org SRC block with a language based on the current mode
and a backlink to the function and the file."
  (with-current-buffer (find-buffer-visiting f)
    (let ((org-src-mode (replace-regexp-in-string "-mode" "" (format "%s" major-mode)))
          (func-name (which-function)))
      (my/org-capture-fileref-snippet f "SRC" org-src-mode func-name))))

(defun my/org-capture-fileref-snippet (f type headers func-name)
  (let* ((code-snippet
          (buffer-substring-no-properties (mark) (- (point) 1)))
         (file-name   (buffer-file-name))
         (file-base   (file-name-nondirectory file-name))
         (line-number (line-number-at-pos (region-beginning)))
         (initial-txt (if (null func-name)
                          (format "From [[file:%s::%s][%s]]:"
                                  file-name line-number file-base)
                        (format "From ~%s~ (in [[file:%s::%s][%s]]):"
                                func-name file-name line-number
                                file-base))))
    (format "
   %s

   #+BEGIN_%s %s
%s
   #+END_%s" initial-txt type headers code-snippet type)))

;; Org-capture
;; Personal snippets
;; Code snippet
(add-to-list 'org-capture-templates
             '("s" "Code snippet"  entry
               (file "~/org/code/snippets.org")
               "* %?\n%(my/org-capture-code-snippet \"%F\")"))
;; Example block snippet
(add-to-list 'org-capture-templates
             '("e" "Example snippet"  entry
               (file "~/org/snippets.org")
               "* %?\n%(my/org-capture-clip-snippet \"%F\")"))
;; Google calendar appointment
(add-to-list 'org-capture-templates
             '("a" "Appointment" entry (file  "~/Dropbox/org/gcal.org" )
               "* %?\n\n%^T\n\n:PROPERTIES:\n\n:END:\n\n"))
;; Journal
(add-to-list 'org-capture-templates
             '("j" "Journal" entry (file+olp+datetree "~/Dropbox/org/journal.org")
               "* %?" :append t))
;; Emacs ideas
(add-to-list 'org-capture-templates
             '("t" "Todo" entry (file+headline "~/org/todo.org" "Inbox")
               "* TODO %?\n%i" :prepend t :kill-buffer t))
;; Work snippets
(add-to-list 'org-capture-templates
             '("S" "Work code snippet"  entry
               (file "~/org/work/snippets.org")
               "* %?\n%(my/org-capture-code-snippet \"%F\")"))
(add-to-list 'org-capture-templates
             '("E" "Work example snippet"  entry
               (file "~/org/work/snippets.org")
               "* %?\n%(my/org-capture-clip-snippet \"%F\")"))
(add-to-list 'org-capture-templates
  '("T" "Work todo" entry (file+headline "~/org/work/todo.org" "Inbox")
     "* [ ] %?\n%i" :prepend t :kill-buffer t))
(add-to-list 'org-capture-templates
             '("J" "Work journal" entry (file+olp+datetree "~/org/work/journal.org")
               "* %?\nEntered on %U\n %i\n %a"))
;; Hugo
;; Populates only the EXPORT_FILE_NAME property in the inserted headline.
(with-eval-after-load 'org-capture
  (defun org-hugo-new-subtree-post-capture-template ()
    "Returns `org-capture' template string for new Hugo post.
See `org-capture-templates' for more information."
    (let* ((title (read-from-minibuffer "Post Title: ")) ;Prompt to enter the post title
           (fname (org-hugo-slug title)))
      (mapconcat #'identity
                 `(
                   ,(concat "* TODO " title)
                   ":PROPERTIES:"
                   ,(concat ":EXPORT_FILE_NAME: " fname)
                   ":END:"
                   "%?\n")          ;Place the cursor here finally
                 "\n")))

  (add-to-list 'org-capture-templates
               '("h"                ;`org-capture' binding + h
                 "Hugo post"
                 entry
                 ;; It is assumed that below file is present in `org-directory'
                 ;; and that it has a "Blog Ideas" heading. It can even be a
                 ;; symlink pointing to the actual location of all-posts.org!
                 (file+olp "todo.org" "Blog Ideas")
                 (function org-hugo-new-subtree-post-capture-template))))

;; Org-babel
(defun src-block-in-session-p (&optional name)
  "Return if src-block is in a session of NAME.
NAME may be nil for unnamed sessions."
  (let* ((info (org-babel-get-src-block-info))
         (lang (nth 0 info))
         (body (nth 1 info))
         (params (nth 2 info))
         (session (cdr (assoc :session params))))

    (cond
     ;; unnamed session, both name and session are nil
     ((and (null session)
           (null name))
      t)
     ;; Matching name and session
     ((and
       (stringp name)
       (stringp session)
       (string= name session))
      t)
     ;; no match
     (t nil))))

(defun org-babel-restart-session-to-point (&optional arg)
  "Restart session up to the src-block in the current point.
Goes to beginning of buffer and executes each code block with
`org-babel-execute-src-block' that has the same language and
session as the current block. ARG has same meaning as in
`org-babel-execute-src-block'."
  (interactive "P")
  (unless (org-in-src-block-p)
    (error "You must be in a src-block to run this command"))
  (let* ((current-point (point-marker))
         (info (org-babel-get-src-block-info))
         (lang (nth 0 info))
         (params (nth 2 info))
         (session (cdr (assoc :session params))))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward org-babel-src-block-regexp nil t)
        ;; goto start of block
        (goto-char (match-beginning 0))
        (let* ((this-info (org-babel-get-src-block-info))
               (this-lang (nth 0 this-info))
               (this-params (nth 2 this-info))
               (this-session (cdr (assoc :session this-params))))
            (when
                (and
                 (< (point) (marker-position current-point))
                 (string= lang this-lang)
                 (src-block-in-session-p session))
              (org-babel-execute-src-block arg)))
        ;; move forward so we can find the next block
        (forward-line)))))

(defun org-babel-kill-session ()
  "Kill session for current code block."
  (interactive)
  (unless (org-in-src-block-p)
    (error "You must be in a src-block to run this command"))
  (save-window-excursion
    (org-babel-switch-to-session)
    (kill-buffer)))

(defun org-babel-remove-result-buffer ()
  "Remove results from every code block in buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward org-babel-src-block-regexp nil t)
      (org-babel-remove-result))))


;;   :config
