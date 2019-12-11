;;; init.el --- Aaron Boyd's Emacs init file
;;; Commentary:
;;


;;; Code:
(setq lexical-binding t)
(add-to-list 'load-path "~/.emacs.d/lisp")
(custom-set-default 'custom-file "~/.emacs.d/lisp/generated-customizations.el")

(load "3p/init-use-package")
(require 'use-package-ensure)
(custom-set-default 'use-package-always-ensure t)

;; Backup file setup
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
                `((".*" ,temporary-file-directory t)))

;; ido
(use-package ido
  :hook 'after-init-hook
  :commands ido-everywhere
  :config
  (ido-mode +1)
  (ido-everywhere +1)
  ;;disable ido faces to see flx highlights.
  (custom-set-default 'ido-use-faces nil)
  (custom-set-variables
   '(ido-use-filename-at-point 'guess)
   '(ido-file-extensions-order '(".ts" ".js"))))

(use-package flx-ido
  :config
  (flx-ido-mode +1))

(use-package ido-completing-read+
  :config
  (ido-ubiquitous-mode +1))

(use-package amx
  :config
  (amx-mode +1))

(use-package ido-vertical-mode
  :config
  (ido-vertical-mode +1)
  (custom-set-variables
   '(ido-vertical-define-keys 'C-n-C-p-up-down-left-right)
  ))

;; Auto Save setup
(custom-set-default 'backup-directory-alist
                    `((".*" . ,temporary-file-directory)))
(custom-set-default 'auto-save-file-name-transforms
                    `((".*" ,temporary-file-directory t)))

(use-package git-gutter
  :config
  (global-git-gutter-mode +1))

;; Show column numbers
(column-number-mode 1)

;; Highlight matching paren
(show-paren-mode 1)

(menu-bar-mode -1)

;; Kill trailing white space
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Smex - Meta-x using ido
;; Loading is delayed until first use
(use-package smex
  :init
  (autoload 'smex "smex"
    "Smex is a M-x enhancement for Emacs, it provides a convenient interface to
your recently and most frequently used commands.")
  :bind
  (("M-x" . 'smex)))

;; quiet, please! No dinging!
;; http://stuff-things.net/2015/10/05/emacs-visible-bell-work-around-on-os-x-el-capitan/
(setq visible-bell nil)
(setq ring-bell-function (lambda ()
			   (invert-face 'mode-line)
			   (run-with-timer 0.1 nil 'invert-face 'mode-line)))

;; Projectile
;; (setq projectile-enable-caching t)
(use-package projectile
  :config
  (projectile-mode +1)
  :bind
  (("C-x t" . 'projectile-find-file)))

;; Use shift-<arrow> to navigate windows
(windmove-default-keybindings)

(use-package multiple-cursors
  :bind
  (("^[ >" . 'mc/mark-next-like-this)
   ("^[ <" . 'mc/mark-previous-like-this)
   ("C-c ^[ <" . 'mc/mark-all-like-this))
  )

;; Commenting regions
(global-set-key (kbd "C-x /") 'comment-region)
(global-set-key (kbd "C-x \\") 'uncomment-region)


(use-package neotree
  :bind
  (("<f8>" . 'neotree-toggle)
   ("<f9>" . 'neotree-find))
  )

;; osx clipboard integration
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

(setq interprogram-cut-function 'paste-to-osx)
(setq interprogram-paste-function 'copy-from-osx)

(use-package elisp-slime-nav
  :init
  (add-hook 'emacs-lisp-mode-hook 'elisp-slime-nav-mode))

(use-package company
  ;; align annotation to the right hand side
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t)

  :init
  ;; begin: fix fxi alignment conflict
  ;; https://github.com/company-mode/company-mode/issues/180
  (defvar company-fci-mode-on-p nil)

  (defun company-turn-off-fci (&rest ignore)
    (when (boundp 'fci-mode)
      (setq-local company-fci-mode-on-p fci-mode)
      (when fci-mode (fci-mode -1))))

  (defun company-maybe-turn-on-fci (&rest ignore)
    (when company-fci-mode-on-p (fci-mode 1)))

  (add-hook 'company-completion-started-hook 'company-turn-off-fci)
  (add-hook 'company-completion-finished-hook 'company-maybe-turn-on-fci)
  (add-hook 'company-completion-cancelled-hook 'company-maybe-turn-on-fci)
  ;; end: fix fxi alignment conflict

  :config
  (let ((item-bg "#333333")
        (item-selected-bg "#665a44"))
    (set-face-background 'company-tooltip item-bg)
    (set-face-background 'company-tooltip-selection item-selected-bg)
    (set-face-background 'company-tooltip-annotation item-bg)
    (set-face-background 'company-tooltip-annotation-selection item-selected-bg)
    (set-face-background 'company-scrollbar-bg "#dcdccc")
    (set-face-background 'company-scrollbar-fg "#878777")
    )
  )

(defun my/init-window-divider ()
  (set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?▐)))
(my/init-window-divider)

(defun my/update-window-divider ()
  (let ((display-table (or buffer-display-table standard-display-table)))
    (set-display-table-slot display-table 'vertical-border (make-glyph-code ?▐))
    (set-window-display-table (selected-window) display-table)))

(use-package fill-column-indicator
  :custom
  (fci-rule-character ?│)
  (fci-rule-column 80)
  :init
  (add-hook 'fci-mode-hook #'my/update-window-divider))

(use-package flycheck
  :custom
  (flycheck-check-syntax-automatically '(save mode-enabled))
  :config
  (set-face-foreground 'vertical-border "#000000")
  (set-face-background 'vertical-border "#111111")
  (set-face-foreground 'flycheck-error "#ff2222")
  (set-face-foreground 'flycheck-warning "#ffdd44")
  (set-face-foreground 'flycheck-info "#44ff44")
  (defun my/flycheck-buffer-status ()
    (when (bound-and-true-p flycheck-mode)
      (let ((error-levels (mapcar 'flycheck-error-level flycheck-current-errors)))
        (cond
         ((seq-contains error-levels 'error) 'error)
         ((seq-contains error-levels 'warning) 'warning)
         ((seq-contains error-levels 'info) 'info)
         (t 'ok)))))
  )

(use-package zenburn-theme
  :custom
  (fci-rule-color "#352035")
  :init
  (setq zenburn-override-colors-alist
        '(("zenburn-bg"    . "#181818")
          ("zenburn-bg-1"  . "#444444")
          ("zenburn-bg-05" . "#111111")
          ))
  :config
  (load-theme 'zenburn t)
  (custom-theme-set-faces
   'zenburn
   `(highlight ((t (:background , "#444444")))))
)


(use-package magit
  :custom
  (magit-log-margin '(t "%Y-%m-%d %I:%M %p" magit-log-margin-width t 18))
  :bind
  (("C-x g" . 'magit-status)))

(use-package rainbow-delimiters)

(defun my/setup-emacs-lisp-mode ()
  "Seteup 'emacs-lisp-mode'."
  (rainbow-delimiters-mode +1)
  (flycheck-mode +1))

(defun my/mode-line-buffer-id (fly-status)
  (let ((label "%b"))
    (cond
     ((eq fly-status 'error)
      (propertize label 'face 'flycheck-error))
     ((eq fly-status 'warning)
      (propertize label 'face 'flycheck-warning))
     ((eq fly-status 'info)
      (propertize label 'face 'flycheck-info))
     (t (propertize label 'face 'mode-line-buffer-id)))))

(custom-set-variables
 '(mode-line-buffer-identification
   '(:eval (my/mode-line-buffer-id (my/flycheck-buffer-status)))))

(add-hook 'prog-mode-hook 'fci-mode)
(add-hook 'prog-mode-hook 'flycheck-mode)
(add-hook 'emacs-lisp-mode-hook #'my/setup-emacs-lisp-mode)

(custom-set-default 'checkdoc-force-docstrings-flag nil)

(load "my/setup-js-editing")
(load "generated-customizations" t)

;;; init.el ends here
