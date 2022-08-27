(add-to-list 'load-path "~/.emacs.d/plugins/base16-emacs")
(add-to-list 'custom-theme-load-path "~/.emacs.d/plugins/base16-emacs/build")
(require 'base16-theme)
(load-theme 'base16-tomorrow-night t)

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
(add-to-list 'load-path "~/.emacs.d/plugins/key-chord")
(require 'key-chord)
(key-chord-mode 1)
(setq key-chord-one-key-delay 0.5)

(add-to-list 'load-path "~/.emacs.d/plugins/evil")
(require 'evil)
(evil-mode 1)

(evil-define-key nil evil-normal-state-map
  "h" 'evil-backward-char
  "t" 'evil-previous-visual-line
  "n" 'evil-next-visual-line
  "s" 'evil-forward-char
  "j" 'evil-search-next
  "l" 'evil-substitute
  "\C-e" 'neotree-toggle
  (kbd "M-.") nil)
(evil-define-key nil evil-motion-state-map
  "h" 'evil-backward-char
  "t" 'evil-previous-line
  "n" 'evil-next-line
  "s" 'evil-forward-char)

(evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
(evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
(evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "g") 'neotree-refresh)
(evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-next-line)
(evil-define-key 'normal neotree-mode-map (kbd "t") 'neotree-previous-line)
(evil-define-key 'normal neotree-mode-map (kbd "A") 'neotree-stretch-toggle)
(evil-define-key 'normal neotree-mode-map (kbd "H") 'neotree-hidden-file-toggle)

(define-key evil-motion-state-map ";" #'evil-ex)
(define-key evil-motion-state-map ":" #'evil-repeat-find-char)
(key-chord-define evil-insert-state-map "hh" 'evil-normal-state)


(add-to-list 'load-path "~/.emacs.d/plugins/swiper")
(require 'ivy)
(require 'counsel)
(ivy-mode 1)

(add-to-list 'load-path "~/.emacs.d/plugins/emacs-neotree")
(require 'neotree)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

(defun my/disable-line-numbers (&optional dummy)
    (display-line-numbers-mode -1))
(add-hook 'neo-after-create-hook 'my/disable-line-numbers)

(add-to-list 'load-path "~/.emacs.d/plugins/geiser/elisp")
(add-to-list 'load-path "~/.emacs.d/plugins/guile")
(require 'geiser)
(require 'geiser-guile)

(with-eval-after-load 'geiser-guile
  (add-to-list 'geiser-guile-load-path "~/src/guix"))

(add-hook 'geiser-keybind-hook
	  (lambda ()
	    (local-set-key (kbd "M-.") 'geiser-edit-symbol-at-point)))

(add-to-list 'load-path "~/.emacs.d/plugins/company-mode")
(require 'company)

(add-to-list 'load-path "~/.emacs.d/plugins/dash.el")
(add-to-list 'load-path "~/.emacs.d/plugins/all-the-icons.el")
(add-to-list 'load-path "~/.emacs.d/plugins/shrink-path.el")
(add-to-list 'load-path "~/.emacs.d/plugins/s.el")
(add-to-list 'load-path "~/.emacs.d/plugins/f.el")
(add-to-list 'load-path "~/.emacs.d/plugins/doom-modeline")
;(require 'doom-modeline)
;(doom-modeline-mode 1)

(add-to-list 'load-path "~/.emacs.d/plugins/misc")
(require 'paredit)

; C
(setq-default c-default-style "linux"
	      c-basic-offset 4)

(setq scroll-conservatively 101)
(set-default 'truncate-lines t)
(global-display-line-numbers-mode)

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


