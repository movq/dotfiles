(add-to-list 'load-path "~/.emacs.d/plugins/atom-one-dark-theme")
(add-to-list 'load-path "~/.emacs.d/plugins/alert")
(add-to-list 'load-path "~/.emacs.d/plugins/all-the-icons.el")
(add-to-list 'load-path "~/.emacs.d/plugins/company-mode")
(add-to-list 'load-path "~/.emacs.d/plugins/dash.el")
(add-to-list 'load-path "~/.emacs.d/plugins/elisp-tree-sitter")
(add-to-list 'load-path "~/.emacs.d/plugins/emacs-neotree")
(add-to-list 'load-path "~/.emacs.d/plugins/erc-hl-nicks")
(add-to-list 'load-path "~/.emacs.d/plugins/evil")
(add-to-list 'load-path "~/.emacs.d/plugins/f.el")
(add-to-list 'load-path "~/.emacs.d/plugins/flycheck")
(add-to-list 'load-path "~/.emacs.d/plugins/geiser/elisp")
(add-to-list 'load-path "~/.emacs.d/plugins/guile")
(add-to-list 'load-path "~/.emacs.d/plugins/ht.el")
(add-to-list 'load-path "~/.emacs.d/plugins/hydra")
(add-to-list 'load-path "~/.emacs.d/plugins/key-chord")
(add-to-list 'load-path "~/.emacs.d/plugins/lsp-mode")
(add-to-list 'load-path "~/.emacs.d/plugins/lsp-mode/clients")
(add-to-list 'load-path "~/.emacs.d/plugins/lsp-ui")
(add-to-list 'load-path "~/.emacs.d/plugins/markdown-mode")
(add-to-list 'load-path "~/.emacs.d/plugins/misc")
(add-to-list 'load-path "~/.emacs.d/plugins/mu4e-alert")
(add-to-list 'load-path "~/.emacs.d/plugins/pfuture")
(add-to-list 'load-path "~/.emacs.d/plugins/prescient.el")
(add-to-list 'load-path "~/.emacs.d/plugins/projectile")
(add-to-list 'load-path "~/.emacs.d/plugins/rust-mode")
(add-to-list 'load-path "~/.emacs.d/plugins/s.el")
(add-to-list 'load-path "~/.emacs.d/plugins/shrink-path.el")
(add-to-list 'load-path "~/.emacs.d/plugins/spinner.el")
(add-to-list 'load-path "~/.emacs.d/plugins/swiper")
(add-to-list 'load-path "~/.emacs.d/plugins/ZNC.el")
(add-to-list 'custom-theme-load-path "~/.emacs.d/plugins/atom-one-dark-theme")
(load-theme 'atom-one-dark t)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "JetBrainsMono Nerd Font Mono" :foundry "DAMA" :slant normal :weight normal :height 160 :width normal)))))

(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
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
  ",p" 'counsel-switch-buffer
  ",f" 'counsel-find-file
  (kbd "SPC p") 'counsel-file-jump
  (kbd "M-.") nil)
(evil-define-key nil evil-motion-state-map
  "h" 'evil-backward-char
  "t" 'evil-previous-line
  "n" 'evil-next-line
  "s" 'evil-forward-char)

;(evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
;(evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
;(evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
;(evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
;(evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
;(evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-next-line)
;(evil-define-key 'normal neotree-mode-map (kbd "t") 'neotree-previous-line)
;(evil-define-key 'normal neotree-mode-map (kbd "A") 'neotree-stretch-toggle)
;(evil-define-key 'normal neotree-mode-map (kbd "H") 'neotree-hidden-file-toggle)

(define-key evil-motion-state-map ";" #'evil-ex)
(key-chord-define evil-insert-state-map "hh" 'evil-normal-state)
;(key-chord-define evil-normal-state-map "gd" 'lsp-find-definition)
;(key-chord-define evil-normal-state-map "gD" 'lsp-find-declaration)
;(key-chord-define evil-normal-state-map "gr" 'lsp-find-references)

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
(set-default 'truncate-lines t)
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
