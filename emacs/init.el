(add-to-list 'load-path "~/.emacs.d/plugins/company-mode")
(add-to-list 'custom-theme-load-path "~/.emacs.d/plugins/atom-one-dark-theme")
(load-theme 'atom-one-dark t)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "JetBrainsMono Nerd Font Mono" :foundry "DAMA" :slant normal :weight normal :height 170 :width normal :background "#080808"))))
 '(fringe ((t (:background "#080808"))))
 '(lsp-ui-doc-background ((t (:background "#151515"))))
 '(markdown-code-face ((t (:inherit default))))
 '(vterm-color-black ((t (:foreground "#282a2e" :background "#373b41"))))
 '(vterm-color-red ((t (:foreground "#a54242" :background "#cc6666"))))
 '(vterm-color-green ((t (:foreground "#8c9440" :background "#b5bd68"))))
 '(vterm-color-yellow ((t (:foreground "#de935f" :background "#f0c674"))))
 '(vterm-color-blue ((t (:foreground "#5f819d" :background "#81a2be"))))
 '(vterm-color-magenta ((t (:foreground "#85678f" :background "#b294bb"))))
 '(vterm-color-cyan ((t (:foreground "#5e8d87" :background "#8abeb7"))))
 '(vterm-color-white ((t (:foreground "#707880" :background "#c5c8c6"))))
 )

(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode 0)

; Evil stuff
(require 'key-chord)
(key-chord-mode 1)
(setq key-chord-one-key-delay 0.5)

(setq evil-want-C-u-scroll t)
(require 'evil)
(evil-mode 1)

(defun movq-kill-current-buffer ()
  (interactive)
  (kill-buffer (current-buffer)))

(evil-define-key nil evil-normal-state-map
  "h" 'evil-backward-char
  "t" 'evil-previous-visual-line
  "n" 'evil-next-visual-line
  "s" 'evil-forward-char
  "j" 'evil-search-next
  "l" 'evil-substitute
  "gr" 'lsp-find-references
  ",k" 'movq-kill-current-buffer
  ",w" 'delete-other-windows
  ",b" 'counsel-switch-buffer
  ",f" 'counsel-find-file
  ",z" 'mpdel-playlist-open
  (kbd "SPC p") 'projectile-switch-project
  (kbd "SPC f") 'projectile-find-file
  (kbd "M-.") nil)

(evil-define-key nil evil-motion-state-map
  "h" 'evil-backward-char
  "t" 'evil-previous-line
  "n" 'evil-next-line
  "s" 'evil-forward-char)

(define-key evil-motion-state-map ";" #'evil-ex)
(key-chord-define evil-insert-state-map "hh" 'evil-normal-state)

(evil-set-initial-state 'mpdel-playlist-mode 'emacs)
(evil-set-initial-state 'mpdel-nav-mode 'emacs)
(evil-set-initial-state 'dired-mode 'emacs)
(evil-set-initial-state 'erc-mode 'normal)

(require 'ivy)
(require 'counsel)
(ivy-mode 1)
(counsel-mode 1)
(define-key ivy-minibuffer-map (kbd "C-t") 'ivy-previous-line)

;(require 'neotree)
;(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

(defun my/disable-line-numbers (&optional dummy)
    (display-line-numbers-mode -1))
(add-hook 'neo-after-create-hook 'my/disable-line-numbers)

(require 'geiser)
(require 'geiser-guile)

(with-eval-after-load 'geiser-guile
  (add-to-list 'geiser-guile-load-path "~/src/guix"))

(add-hook 'geiser-keybind-hook
	  (lambda ()
	    (local-set-key (kbd "M-.") 'geiser-edit-symbol-at-point)))

(add-hook 'scheme-mode-hook
          (lambda ()
            (put 'eval-when 'scheme-indent-function 1)
            (put 'call-with-prompt 'scheme-indent-function 1)
            (put 'test-assert 'scheme-indent-function 1)
            (put 'test-assertm 'scheme-indent-function 1)
            (put 'test-equalm 'scheme-indent-function 1)
            (put 'test-equal 'scheme-indent-function 1)
            (put 'test-eq 'scheme-indent-function 1)
            (put 'call-with-input-string 'scheme-indent-function 1)
            (put 'call-with-port 'scheme-indent-function 1)
            (put 'guard 'scheme-indent-function 1)
            (put 'lambda* 'scheme-indent-function 1)
            (put 'substitute* 'scheme-indent-function 1)
            (put 'match-record 'scheme-indent-function 2)

            ;; 'modify-inputs' and its keywords.
            (put 'modify-inputs 'scheme-indent-function 1)
            (put 'replace 'scheme-indent-function 1)

            ;; 'modify-phases' and its keywords.
            (put 'modify-phases 'scheme-indent-function 1)
            (put 'replace 'scheme-indent-function 1)
            (put 'add-before 'scheme-indent-function 2)
            (put 'add-after 'scheme-indent-function 2)

            (put 'modify-services 'scheme-indent-function 1)
            (put 'with-directory-excursion 'scheme-indent-function 1)
            (put 'with-file-lock 'scheme-indent-function 1)
            (put 'with-file-lock/no-wait 'scheme-indent-function 1)
            (put 'with-profile-lock 'scheme-indent-function 1)
            (put 'with-writable-file 'scheme-indent-function 2)

            (put 'package 'scheme-indent-function 0)
            (put 'package/inherit 'scheme-indent-function 1)
            (put 'origin 'scheme-indent-function 0)
            (put 'build-system 'scheme-indent-function 0)
            (put 'bag 'scheme-indent-function 0)
            (put 'gexp->derivation 'scheme-indent-function 1)
            (put 'graft 'scheme-indent-function 0)
            (put 'operating-system 'scheme-indent-function 0)
            (put 'file-system 'scheme-indent-function 0)
            (put 'manifest-entry 'scheme-indent-function 0)
            (put 'manifest-pattern 'scheme-indent-function 0)
            (put 'substitute-keyword-arguments 'scheme-indent-function 1)
            (put 'with-store 'scheme-indent-function 1)
            (put 'with-external-store 'scheme-indent-function 1)
            (put 'with-error-handling 'scheme-indent-function 0)
            (put 'with-mutex 'scheme-indent-function 1)
            (put 'with-atomic-file-output 'scheme-indent-function 1)
            (put 'call-with-compressed-output-port 'scheme-indent-function 2)
            (put 'call-with-decompressed-port 'scheme-indent-function 2)
            (put 'call-with-gzip-input-port 'scheme-indent-function 1)
            (put 'call-with-gzip-output-port 'scheme-indent-function 1)
            (put 'call-with-lzip-input-port 'scheme-indent-function 1)
            (put 'call-with-lzip-output-port 'scheme-indent-function 1)
            (put 'signature-case 'scheme-indent-function 1)
            (put 'emacs-batch-eval 'scheme-indent-function 0)
            (put 'emacs-batch-edit-file 'scheme-indent-function 1)
            (put 'emacs-substitute-sexps 'scheme-indent-function 1)
            (put 'emacs-substitute-variables 'scheme-indent-function 1)
            (put 'with-derivation-narinfo 'scheme-indent-function 1)
            (put 'with-derivation-substitute 'scheme-indent-function 2)
            (put 'with-status-report 'scheme-indent-function 1)
            (put 'with-status-verbosity 'scheme-indent-function 1)
            (put 'with-build-handler 'scheme-indent-function 1)

            (put 'mlambda 'scheme-indent-function 1)
            (put 'mlambdaq 'scheme-indent-function 1)
            (put 'syntax-parameterize 'scheme-indent-function 1)
            (put 'with-monad 'scheme-indent-function 1)
            (put 'mbegin 'scheme-indent-function 1)
            (put 'mwhen 'scheme-indent-function 1)
            (put 'munless 'scheme-indent-function 1)
            (put 'mlet* 'scheme-indent-function 2)
            (put 'mlet 'scheme-indent-function 2)
            (put 'mparameterize 'scheme-indent-function 2)
            (put 'run-with-store 'scheme-indent-function 1)
            (put 'run-with-state 'scheme-indent-function 1)
            (put 'wrap-program 'scheme-indent-function 1)
            (put 'wrap-script 'scheme-indent-function 1)
            (put 'with-imported-modules 'scheme-indent-function 1)
            (put 'with-extensions 'scheme-indent-function 1)
            (put 'with-parameters 'scheme-indent-function 1)
            (put 'let-system 'scheme-indent-function 1)
            (put 'with-build-variables 'scheme-indent-function 2)

            (put 'with-database 'scheme-indent-function 2)
            (put 'call-with-database 'scheme-indent-function 1)
            (put 'call-with-transaction 'scheme-indent-function 1)
            (put 'with-statement 'scheme-indent-function 3)
            (put 'call-with-retrying-transaction 'scheme-indent-function 1)
            (put 'call-with-savepoint 'scheme-indent-function 1)
            (put 'call-with-retrying-savepoint 'scheme-indent-function 1)

            (put 'call-with-container 'scheme-indent-function 1)
            (put 'container-excursion 'scheme-indent-function 1)
            (put 'eventually 'scheme-indent-function 1)

            (put 'call-with-progress-reporter 'scheme-indent-function 1)
            (put 'with-repository 'scheme-indent-function 2)
            (put 'with-temporary-git-repository 'scheme-indent-function 2)
            (put 'with-environment-variables 'scheme-indent-function 1)
            (put 'with-fresh-gnupg-setup 'scheme-indent-function 1)

            (put 'with-paginated-output-port 'scheme-indent-function 1)

            (put 'with-shepherd-action 'scheme-indent-function 3)

            (put 'with-http-server 'scheme-indent-function 1)))

(require 'company)
(add-hook 'after-init-hook 'global-company-mode)

(require 'paredit)
(defun enable-paredit-mode ()
    (paredit-mode))
(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
(add-hook 'scheme-mode-hook 'enable-paredit-mode)

; C
(setq-default c-default-style "linux"
	      c-basic-offset 4)

(setq scroll-conservatively 101)
;(set-default 'truncate-lines t)
;(global-display-line-numbers-mode)

(setq frame-title-format
  '((:eval (if (buffer-file-name)
                (abbreviate-file-name (buffer-file-name))
                  "%b"))))

(setq backup-directory-alist
	`(("." . ,(concat user-emacs-directory "backups"))))

(auto-save-visited-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(evil-undo-system 'undo-redo)
 '(safe-local-variable-values
   '((eval progn
           (require 'lisp-mode)
           (defun emacs27-lisp-fill-paragraph
               (&optional justify)
             (interactive "P")
             (or
              (fill-comment-paragraph justify)
              (let
                  ((paragraph-start
                    (concat paragraph-start "\\|\\s-*\\([(;\"]\\|\\s-:\\|`(\\|#'(\\)"))
                   (paragraph-separate
                    (concat paragraph-separate "\\|\\s-*\".*[,\\.]$"))
                   (fill-column
                    (if
                        (and
                         (integerp emacs-lisp-docstring-fill-column)
                         (derived-mode-p 'emacs-lisp-mode))
                        emacs-lisp-docstring-fill-column fill-column)))
                (fill-paragraph justify))
              t))
           (setq-local fill-paragraph-function #'emacs27-lisp-fill-paragraph))
     (eval modify-syntax-entry 43 "'")
     (eval modify-syntax-entry 36 "'")
     (eval modify-syntax-entry 126 "'")
     (eval let
           ((root-dir-unexpanded
             (locate-dominating-file default-directory ".dir-locals.el")))
           (when root-dir-unexpanded
             (let*
                 ((root-dir
                   (expand-file-name root-dir-unexpanded))
                  (root-dir*
                   (directory-file-name root-dir)))
               (unless
                   (boundp 'geiser-guile-load-path)
                 (defvar geiser-guile-load-path 'nil))
               (make-local-variable 'geiser-guile-load-path)
               (require 'cl-lib)
               (cl-pushnew root-dir* geiser-guile-load-path :test #'string-equal))))
     (eval setq-local guix-directory
           (locate-dominating-file default-directory ".dir-locals.el")))))

(require 'ivy-prescient)
(ivy-prescient-mode 1)
(prescient-persist-mode 1)

(require 'flycheck)
(require 'lsp-mode)
(require 'lsp-ui)
(require 'lsp-clangd)
(require 'lsp-rust)

(add-hook 'c++-mode-hook 'lsp)
(add-hook 'guile-mode-hook 'geiser-guile)

(require 'znc)
(setq znc-servers
    '(("ulmo.vala.xyz" 1025 t
      ((libera "mike/libera" "")))))

(require 'erc-hl-nicks)
(setq erc-hide-list '("JOIN" "PART" "QUIT"))

;(require 'treemacs)

(setq gnus-select-method
      '(nnmaildir "FastMail"
		(directory "~/mail")
		(get-new-mail nil)))
(setq-default indent-tabs-mode nil)

(require 'rust-mode)
;(require 'tree-sitter)
;(require 'tree-sitter-hl)
;(require 'tree-sitter-langs)
;(require 'tree-sitter-debug)
;(require 'tree-sitter-query)

(add-hook 'rust-mode-hook #'tree-sitter-mode)
(require 'mu4e)
(setq shr-color-visible-luminance-min 80)

(setq mu4e-get-mail-command "offlineimap")
(setq mu4e-update-interval 300)
(setq mu4e-headers-auto-update t)
(setq mu4e-hide-index-messages t)
(setq
  mu4e-sent-folder   "/Sent"       ;; folder for sent messages
  mu4e-drafts-folder "/Drafts"     ;; unfinished messages
  mu4e-trash-folder  "/Trash"      ;; trashed messages
  mu4e-refile-folder "/Archive")   ;; saved messages

(require 'mu4e-alert)
(mu4e-alert-set-default-style 'libnotify)
(add-hook 'after-init-hook #'mu4e-alert-enable-notifications)
(add-hook 'after-init-hook #'mu4e-alert-enable-mode-line-display)

(require 'projectile)
(setq projectile-project-search-path '("~/src"))
(projectile-mode)
(add-to-list 'default-frame-alist '(background-color . "#080808"))

(require 'mpdel)
(setq libmpdel-hostname "/home/mike/.config/mpd/socket")
(mpdel-mode)

(put 'magit-clean 'disabled nil)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq geiser-debug-jump-to-debug-p nil)
