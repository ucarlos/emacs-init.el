;; -----------------------------------------------------------------------------
;; Emacs Initalization file for Ulysses-H270
;; Please try to comment as much as you can in this file.
;; 
;; ------------------------------------------------------------------------------
;; KEYBINDS

(global-set-key (kbd "<mouse-8>") 'previous-buffer)
(global-set-key (kbd "<mouse-9>") 'next-buffer)
;;------------------------------------------------------------------------------
;; Enable MELPA repository

(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
  ;; and `package-pinned-packages`. Most users will not need or want to do this.
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  )
(package-initialize)

;;------------------------------------------------------------------------------
;; Enable Deferred Compliation
(setq comp-deferred-compilation t)

;;------------------------------------------------------------------------------
;; Paradox as default package manager:
(require 'paradox)
(paradox-enable)
;;------------------------------------------------------------------------------

;;------------------------------------------------------------------------------
;; Allow sudo edit:
(require 'sudo-edit)
;;------------------------------------------------------------------------------

;; Word wrap:
(global-visual-line-mode t)
(show-paren-mode 1)

;; Save desktop status
 (desktop-save-mode 1)

(setq TeX-PDF-mode t)
;; Custom Set Variables moved to custom.el because it was too long.
 (setq custom-file "~/.emacs.d/custom.el")
 (load custom-file)

;;------------------------------------------------------------------------------
;; Set up pdf tools
;; (pdf-tools-install)
(pdf-loader-install)
 ;; automatically annotate highlights


;; Set a limit of pdf-tools cache; In this case it's 30 seconds.
;; (setq image-cache-eviction-delay X) ;; X is any amount of seconds.
(setq image-cache-eviction-delay 5)

(setq pdf-cache-image-limit 32) ;; Cache will be cleared after 32 images have been viewed.
;; PDF-view-restore
(use-package pdf-view-restore
  :after pdf-tools
  :config
  (add-hook 'pdf-view-mode-hook 'pdf-view-restore-mode))

;;------------------------------------------------------------------------------
;; Display Time without load:
;;------------------------------------------------------------------------------

(setq display-time-default-load-average nil)
(display-time-mode)

;; Remove ALL buffers:
(defun kill-all-buffers ()
  (interactive)
  (mapc 'kill-buffer (buffer-list)))

;;------------------------------------------------------------------------------
;; Custom Functions
;;------------------------------------------------------------------------------


(defun recompile-elpa-packages ()
  (interactive)
  (byte-recompile-directory package-user-dir nil 'force))



(defun generate-banner (name time file-name space comment-delimiter line-length)
  "Generate a banner given a list of parameters."
  (interactive)
  
  (defvar line (make-string (- line-length 2 (length space)) ?-))
  (insert space comment-delimiter " " line)
  (insert "\n" space comment-delimiter " Created by " name " on " time)
  (insert "\n" space comment-delimiter)
  (insert "\n" space comment-delimiter " " file-name)
  (insert "\n" space comment-delimiter)
  (insert "\n" space comment-delimiter " " line "\n"))


(defun c-banner ()
  "Create a banner for .c and .cc files."
  (interactive)
  (defvar line_count 80) ;; Standard 80-char terminal
 
  (let ((file-name " ") (time-stamp " "))
    (setq time-stamp (format-time-string "%m/%d/%Y at %I:%M %p" ))
    
    (setq file-name (substring (buffer-file-name) (string-match "[^/]+$" (buffer-file-name))))
    
    (insert "/*\n") ;; Line 1
    (generate-banner "Ulysses Carlos" time-stamp file-name " " "*" line_count)
    (insert " */" "\n\n")))


(defun check-c-banner ()
  "Check if a banner can be printed on a .c or .cc file."
  (let ((current-size 0))
    (setq current-size (buffer-size)) ;; Assign current-size
    (when (= current-size 0) (c-banner))))


(defun py-banner ()
  "Create a banner for .py files."
  (interactive)
  
  (defvar line-count 80)

  (let ((file-name " ") (time-stamp " "))
    (setq time-stamp (format-time-string "%m/%d/%Y at %I:%M %p" ))
    
    (setq file-name (substring (buffer-file-name) (string-match "[^/]+$" (buffer-file-name))))
    
    (generate-banner "Ulysses Carlos" time-stamp file-name "" "#" line-count)))


(defun check-py-banner ()
  "Only print a banner on an empty Python file."
					; Get size of buffer:
  ;; (interactive)
  (let ((current-size 0))
    (setq current-size (buffer-size)) ;; Assign current-size
    (when (= current-size 0) (py-banner))))


(defun lisp-banner ()
  "Create a banner for Lisp files."
  (interactive)
  (defvar line-count 80) ;; Standard 80-char terminal
  
  (let ((file-name " ") (time-stamp " "))
    (setq time-stamp (format-time-string "%m/%d/%Y at %I:%M %p" ))
    
    (setq file-name (substring (buffer-file-name) (string-match "[^/]+$" (buffer-file-name))))
    
    (generate-banner "Ulysses Carlos" time-stamp file-name "" ";" line-count)))

(defun check-lisp-banner ()
  "Print a banner on an empty Lisp file only."
					; Get size of buffer:
  ;; (interactive)
  (let ((current-size 0))
    (setq current-size (buffer-size)) ;; Assign current-size
    (when (= current-size 0) (lisp-banner))))



(defun kill-dired-buffers ()
  (interactive)
  (mapc (lambda (buffer) 
	  (when (eq 'dired-mode (buffer-local-value 'major-mode buffer)) 
	    (kill-buffer buffer))) 
	(buffer-list)))


;;------------------------------------------------------------------------------
;; Banner hooks for different programming modes should be placed here.
;;------------------------------------------------------------------------------

;; C-like commenting
(add-hook 'c-mode-hook 'check-c-banner)
(add-hook 'c++-mode-hook 'check-c-banner)
(add-hook 'java-mode-hook 'check-c-banner)


;; Python-like commenting
(add-hook 'python-mode-hook 'check-py-banner)
(add-hook 'ruby-mode-hook 'check-py-banner) ;; Ruby allows for python-like commenting
(add-hook 'sh-mode-hook 'check-py-banner)


;; Lisp-like commenting
(add-hook 'lisp-mode-hook 'check-lisp-banner)

;;------------------------------------------------------------------------------
;; Emacs Appearance/Theme
;;------------------------------------------------------------------------------

(load-theme 'flatfluc t)

;; Tell Emacs where is your personal theme directory
;;(add-to-list 'custom-theme-load-path (expand-file-name "/home/ulysses/.emacs.d/themes/smart-mode-line-atom-one-dark-theme"
;;                                                   ))

;;(setq sml/theme 'atom-one-dark)
(setq sml/theme 'respectful)
(sml/setup)

;;------------------------------------------------------------------------------
;; Magit
;;------------------------------------------------------------------------------

(global-set-key (kbd "C-x g") 'magit-status)


;; (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
;; (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
(global-diff-hl-mode)



;;------------------------------------------------------------------------------
;; EMMS (Emacs Media Manager System)
;;------------------------------------------------------------------------------

(add-to-list 'load-path "~/.emacs.d/emms/lisp/")
(require 'emms-setup)
(emms-all)
(emms-default-players)

(emms-history-load)

(setq emms-player-list (list emms-player-mpv)
      emms-source-file-default-directory (expand-file-name "~/Music/Music by Genre/")
      emms-source-file-directory-tree-function 'emms-source-file-directory-tree-find
      emms-browser-covers 'emms-browser-cache-thumbnail)
(add-to-list 'emms-player-mpv-parameters "--no-audio-display")
(add-to-list 'emms-info-functions 'emms-info-cueinfo)
(add-to-list 'emms-info-functions 'emms-info-opusinfo)
(if (executable-find "emms-print-metadata")
    (progn
      (require 'emms-info-libtag)
      (setq emms-info-functions '(emms-info-libtag))
      (add-to-list 'emms-info-functions 'emms-info-opusinfo)))
  
(defun ambrevar/emms-play-on-add (old-pos)
  "Play tracks when calling `emms-browser-add-tracks' if nothing is currently playing."
  (interactive)
  (when (or (not emms-player-playing-p)
            emms-player-paused-p
            emms-player-stopped-p)
    (with-current-emms-playlist
      (goto-char old-pos)
      ;; if we're sitting on a group name, move forward
      (unless (emms-playlist-track-at (point))
        (emms-playlist-next))
      (emms-playlist-select (point)))
    (emms-stop)
    (emms-start)))
(add-hook 'emms-browser-tracks-added-hook 'ambrevar/emms-play-on-add)


;; Currently disabled because the librefm scrobbler doesn't work for whatever reason.
;; (emms-librefm-scrobbler-enable)

;;------------------------------------------------------------------------------
;; EMMS: Play Random album

(defun goto-random-line ()
  "Go to a random line in this buffer."
  ; good for electrobibliomancy.
  (interactive)
  (goto-line (1+ (random (buffer-line-count)))))
 
(defun buffer-line-count () 
  "Return the number of lines in this buffer."
  (count-lines (point-min) (point-max))) 
 
;; (defun emms-random-album-enqueue ()
;;   (interactive)
;;   (emms-browse-by-album)
;;   (goto-random-line)
;;   (emms-browser-add-tracks))
 
 
;; (defun emms-random-albums-enqueue (desired-number)
;;   "Enqueue a desired number of random albums"
;;   (interactive "How many albums you want enqueued: ")
;;   (message "Number of albums added: %d" desired-number)
;;   (setq count 0)
;;   (emms-browse-by-album)
;;   (while (< count desired-number)
;;     (goto-random-line)
;;     (emms-browser-add-tracks)
;;     (setq count (+ 1 count)))
;;   )

(defun emms-random-albums-play (desired-number)
  "Play a desired number of random albums"
  (interactive "nHow many albums you want played: ")
  (message "Number of albums added: %d" desired-number)
  (emms-browse-by-album)
  (goto-random-line)
  (emms-browser-add-tracks-and-play)
  (setq count 1)
  (while (< count desired-number)
    (goto-random-line)
    (emms-browser-add-tracks)
    (setq count (+ 1 count)))
)
 
(provide 'emms-random-album)


;;------------------------------------------------------------------------------
;;------------------------------------------------------------------------------
;; Sunshine (Weather Application)
;; (require 'sunshine)
;; ;; Set location
;; (setq sunshine-location "Atlanta,GA")
;; (setq sunshine-show-icons t)
;; ; Set openweather api key
;; (setq sunshine-appid "3a5e64582f128856ea72254d98c0331d")
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Dired Improvements:
;;------------------------------------------------------------------------------

;; always execute dired-k when dired buffer is opened
(add-hook 'dired-initial-position-hook 'dired-k)
;; Add All-the-icons mode to dired:
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
(add-hook 'dired-after-readin-hook #'dired-k-no-revert)

;;------------------------------------------------------------------------------
;; Emacs Enchancements:
;; 
;; Wind Move
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))
;; END of Wind Move

;; Smex 
  (require 'smex) ; Not needed if you use package.el
  (smex-initialize) ; Can be omitted. This might cause a (minimal) delay
                    ; when Smex is auto-initialized on its first run.
(global-set-key (kbd "M-x") 'smex)
  (global-set-key (kbd "M-X") 'smex-major-mode-commands)
  ;; This is your old M-x.
  (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
;; END of Smex

;; Linenum Relative:
;; (require 'linum-relative)
;; (linum-on)
;;

;; Beacon mode:
(beacon-mode 1)

;;Solaire Mode:
(require 'solaire-mode)
(add-hook 'change-major-mode-hook #'turn-on-solaire-mode)

;; Enable Flyspell Mode:
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)


(global-flycheck-mode)

(with-eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook 'flycheck-popup-tip-mode))



;;------------------------------------------------------------------------------
;; Org Mode Enchancements
;;------------------------------------------------------------------------------

(add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))

(require 'company-org-block)

(setq company-org-block-edit-style 'auto) ;; 'auto, 'prompt, or 'inline

(add-hook 'org-mode-hook
          (lambda ()
            (add-to-list (make-local-variable 'company-backends)
                         'company-org-block)))

;;------------------------------------------------------------------------------
;; Coding Enhancements:
;;------------------------------------------------------------------------------

;; Force indentation by spaces:
(setq-default indent-tabs-mode nil)

;; BASIC COMPANY MODE
(add-hook 'after-init-hook 'global-company-mode)

;; BASIC AUTOCOMPLETE MODE:
(ac-config-default)


;;------------------------------------------------------------------------------
;; LSP-Mode Configuration
;;------------------------------------------------------------------------------
;; lsp-clients-clangd-executable
(require 'lsp-mode)

;; Enable with treemacs
(lsp-treemacs-sync-mode 1)

;; Some package causes the issue here.
(setq package-selected-packages '(lsp-mode yasnippet lsp-treemacs helm-lsp
    projectile hydra flycheck company avy which-key helm-xref dap-mode))

;; (when (cl-find-if-not #'package-installed-p package-selected-packages)
;;   (package-refresh-contents)
;;   (mapc #'package-install package-selected-packages))

;; sample `helm' configuration use https://github.com/emacs-helm/helm/ for details
(helm-mode)
(require 'helm-xref)
;; (define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-m-x)
;; (define-key global-map [remap switch-to-buffer] #'helm-mini)

(which-key-mode)


;;------------------------------------------------------------------------------
;; Shell Scripting
;;------------------------------------------------------------------------------
(add-hook 'sh-mode-hook 'flymake-shellcheck-load)
(add-hook 'sh-mode-hook 'lsp)

;;------------------------------------------------------------------------------
;; C/C++ Development Tools
;;------------------------------------------------------------------------------

;; Define a personal C/C++ Style:

(defun uly-c-mode-common-hook ()
  ;; Set my personal style for the current buffer
  ;; The default C/C++ style is a mixture b/w stroustrup and java.
  ;; Basically, keep stroustrup class and conditional indention, but make it like
  ;; java in that the opening function bracket is on the same line as the function
  ;; declaration. Also, default indention is 4 and tabs are used instead.    
  (setq c-basic-offset 4
		tab-width 4
		c-default-style "linux"))

;; Now add it to C and C++
(add-hook 'c-mode-common-hook 'uly-c-mode-common-hook)
(add-hook 'c++-mode-hook 'uly-c-mode-common-hook)



;; Modern C++ Syntax
(require 'modern-cpp-font-lock)
(modern-c++-font-lock-global-mode t)

;; Disable Company mode for gdb:
(setq company-global-modes '(not gud-mode))
(setq company-global-modes '(not org-mode))
(setq company-global-modes '(not racket-mode))
(add-to-list 'company-backends 'company-web-html)
(add-to-list 'company-backends 'company-web-jade)
(add-to-list 'company-backends 'company-web-slim)


;;------------------------------------------------------------------------------
;; C++ LSP Configuration 
;;------------------------------------------------------------------------------


(add-hook 'c-mode-hook 'lsp)

(add-hook 'c++-mode-hook 'lsp)

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.1 ;; clangd is fast
      ;; be more ide-ish
      lsp-headerline-breadcrumb-enable t)

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  ;; HERE LIES THE PROBLEM::::::::::::  
  ;; (require 'dap-cpptools) ;; Okay, this might be the issue.
  (require 'dap-gdb-lldb)
  (yas-global-mode))

;; Disable Logging
(setq lsp-log-io nil) ; if set to true can cause a performance hit.

;;------------------------------------------------------------------------------
;; C# Development
;;------------------------------------------------------------------------------
(add-hook 'csharp-mode-hook 'lsp)
(add-hook 'csharp-mode-hook 'check-c-banner)


;;------------------------------------------------------------------------------
;; Java Development (LSP is way too slow so don't bother)
;;------------------------------------------------------------------------------
(add-hook 'java-mode-hook 'lsp)


(use-package dap-java
  :after (dap-mode lsp-java cl)
  :init
  (defhydra dap-java-testrun-hydra (:hint nil :color blue)
    "
^Debug^                         ^Run Test^                          ^Other^
-----------------------------------------------------------------------------------
_d_: dap-debug-java             _r c_: dap-java-run-test-class     _h_ dap-hydra
_c_: dap-java-run-test-class    _r m_: dap-java-run-test-method
_m_: dap-java-run-test-method"
    ("d" dap-debug-java)
    ("c" dap-java-debug-test-class)
    ("m" dap-java-debug-test-method)
    ("r c" dap-java-run-test-class)
    ("r m" dap-java-run-test-method)
    ("h" dap-hydra))
)


;;------------------------------------------------------------------------------
;; Python Development:
;;------------------------------------------------------------------------------


;;--------------------------------------
;; Virtualenv:
;;--------------------------------------
;; Bug fix for elpy:


;;--------------------------------------
;; Python lsp with pyls (Works but slow compared to others?)
;;--------------------------------------

(use-package lsp-mode
  :config
  (setq lsp-idle-delay 0.5
        lsp-enable-symbol-highlighting t
        lsp-enable-snippet nil  ;; Not supported by company capf, which is the recommended company backend
        lsp-pyls-plugins-flake8-enabled nil)
  (lsp-register-custom-settings
   '(("pyls.plugins.pyls_mypy.enabled" t t)
     ("pyls.plugins.pyls_mypy.live_mode" nil t)
     ("pyls.plugins.pyls_black.enabled" t t)
     ("pyls.plugins.pyls_isort.enabled" t t)

     ;; Disable these as they're duplicated by flake8
     ;; ("pyls.plugins.pycodestyle.enabled" nil)
     ;; ("pyls.plugins.mccabe.enabled" nil)
     ;; ("pyls.plugins.pyflakes.enabled" nil)
   ))
  :hook
  ((python-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration)))

(use-package lsp-ui
  :config (setq lsp-ui-sideline-show-hover t
                lsp-ui-sideline-delay 0.5
                lsp-ui-doc-delay 5
                lsp-ui-sideline-ignore-duplicates t
                lsp-ui-doc-position 'bottom
                lsp-ui-doc-alignment 'frame
                lsp-ui-doc-header nil
                lsp-ui-doc-include-signature t
                lsp-ui-doc-use-childframe t)
  :commands lsp-ui-mode)

;; Bug fix for elpy:
(setq python-shell-interpreter "ipython3"
      python-shell-interpreter-args "-i --simple-prompt")

(require 'dap-python)
;; Set pydoc to C-c C-d:
;; (add-hook 'lsp-mode-hook
;; 	  (lambda ()
;; 	    (local-set-key "C-c C-d" 'pydoc)))


;;------------------------------------------------------------------------------
;; SQL Enchancements
;;------------------------------------------------------------------------------

;; Uppercase SQL keywords
(add-hook 'sql-mode-hook 'sqlup-mode)
(add-hook 'sql-interactive-mode-hook 'sqlup-mode)

;;------------------------------------------------------------------------------
;; HTML/CSS Development
;;------------------------------------------------------------------------------

(add-hook 'html-mode-hook
  (lambda ()
    ;; Default indentation is usually 2 spaces, changing to 4.
    (set (make-local-variable 'sgml-basic-offset) 4)))
(add-hook 'html-mode-hook 'lsp)
(add-hook 'css-mode-hook 'lsp)


;;------------------------------------------------------------------------------
;; TypeScript/JavaScript Development (ts-ls at the moment since
;;                                    deno just randomly lags sometimes)
;;------------------------------------------------------------------------------

(add-hook 'js-mode-hook 'check-c-banner)
(add-hook 'js-mode-hook 'lsp)


;;------------------------------------------------------------------------------
;; Circe IRC Settings
;;------------------------------------------------------------------------------

(setq circe-network-options
      '(("Libera"
         :tls t
         :nick "my-nick"
         :sasl-username "my-nick"
         :sasl-password "my-password"
         :channels ("#emacs-circe"))))



;; Custom Emacs functions:

(defun kill-other-buffers ()
      "Kill all other buffers."
      (interactive)
      (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))

;;------------------------------------------------------------------------------
;;------------------------------------------------------------------------------
(put 'downcase-region 'disabled nil)
(put 'erase-buffer 'disabled nil)


;;------------------------------------------------------------------------------
;; End of File.
;;------------------------------------------------------------------------------
