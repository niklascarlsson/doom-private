;;; packages.el -*- lexical-binding: t; -*-

;; apps
(package! ivy-youtube)
(package! transmission)

;; org
(package! org-mime)

;; window manager
(package! exwm :recipe (:type git :host github :repo "ch11ng/exwm"))
(package! exwm-edit :recipe (:type git :host github :repo "agzam/exwm-edit"))

;; system
(package! guix)
(package! dired-recent)
(package! dired-subtree)
(package! dired-narrow)
(package! disk-usage)
(package! emacs-conflicts :recipe (:host github :repo "ibizaman/emacs-conflicts" :branch "master"))
(package! bluetooth)
(package! alert)
(package! gif-screencast)

;; mail
(package! notmuch)
(package! counsel-notmuch)

;; package development
(package! navigel)
(package! emacsql)
(package! emacsql-sqlite)
