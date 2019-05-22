;; * Encapsulate my customization inside a function
;    that gets called through radian-after-init-hook
(defun radian-local--after-init ()
;; ** Auto Encryption/Decryption support for gpg and asc files
 (setq epa-armor t)
 (setq epa-file-name-regexp "\\.\\(gpg\\|asc\\)$")
 (epa-file-name-regexp-update)

;; ** csv-mode package
 (use-package csv-mode)

;; ** 'general' package
 (use-package general
   ;;mbk :straight t
   :demand t
   :config
   (general-override-mode))

;; *** Create our own definer and make 'SPC' the leader key
 ;;    straight from general docuentation
 (general-create-definer tyrant-def
   :states '(normal motion visual insert emacs)
   :prefix "SPC"
   :non-normal-prefix "M-SPC"
   :prefix-command 'tyrant-prefix-command
   :prefix-map 'tyrant-prefix-map)

;; ** evil package
  (use-package evil
    ;;mbk :straight t
    :demand t
    :init
    (setq evil-want-keybinding nil)
    (setq evil-want-integration nil)
    :general
    ;; more than one keybinding can be specified for any given keyward can be specified this way
    ;; don't understand the concept of keyword arguments and how parameters are bound to arguments
    ;; move over visual lines like normal lines
    (:states '(motion normal)
             "j" #'evil-next-visual-line
             "k" #'evil-previous-visual-line)
    ;; z+ originally == evil-scroll-bottom-line-to-top -- rarely needed.
    ;; repurpose to text scaling
    (:states '(visual normal)
             "z+" #'text-scale-adjust)
    :config
    (progn
      (setq evil-search-module 'evil-search)
      (setq evil-magic 'very-magic)
      ;; (setq evil-want-C-i-jump nil)
      (add-hook 'git-commit-mode-hook 'evil-insert-state)
      (evil-set-initial-state 'messages-buffer-mode 'normal)
      (evil-set-initial-state 'magit-log-edit-mode 'insert)
      ;; evil-normal-state is preferred, so revert when idle
      (run-with-idle-timer 60 t 'evil-normal-state)
      ;; do/don't echo evil state
      (setq evil-echo-state t)
      ;; don't move cursor back when exiting insert state
      (setq evil-move-cursor-back nil)
      ;; evil everywhere
      (evil-mode 1)
      ))

  (use-package evil-indent-textobject
    ;;mbk :straight t
    :after evil
    :commands (evil-indent))

  (use-package evil-surround
    ;; :commands (evil-surround-region evil-surround-change evil-surround-delete)
    ;; :hook ((LaTeX-mode org-mode markdown-mode prog-mode) . evil-surround-mode)
    ;;mbk :straight t
    ;;mbk :general
    ;;mbk (:states '(visual)
    ;;mbk          "s" 'evil-surround-region
    ;;mbk          "S" 'evil-substitute)
    :after evil
    :defer 1
    :config
    (global-evil-surround-mode 1)
    )

  (use-package evil-commentary
    ;;mbk :straight t
    :after evil
    :commands (evil-commentary evil-commentary-line)
    ;; :diminish evil-commentary-mode
    :config
    (evil-commentary-mode))

  (use-package evil-escape
    :after evil
    :init (evil-escape-mode)
    :config
    (setq-default evil-escape-key-sequence "qn")
    (setq-default evil-escape-undordered-key-sequence t)
    )

  (use-package evil-text-object-python
    :after evil
    :hook ((python-mode . evil-text-object-python-add-bindings)))

  ;;mbk (use-package evil-mc
  ;;mbk   :straight t
  ;;mbk   ;;mbk :commands (evil-mc-make-all-cursors evil-mc-make-and-goto-next-match))
  ;;mbk   :config
  ;;mbk   (global-evil-mc-mode 1))

  ;;mbk (use-package evil-numbers
  ;;mbk   :straight t
  ;;mbk   :commands (evil-numbers/inc-at-pt evil-numbers/dec-at-pt)
  ;;mbk   :init
  ;;mbk   :general
  ;;mbk   (:states '(normal)
  ;;mbk    "C-c +" 'evil-numbers/inc-at-pt
  ;;mbk    "C-c -" 'evil-numbers/dec-at-pt)

  (use-package evil-visualstar
    ;;mbk :straight t
    :after evil
    ;;mbk :commands (evil-visualstar/begin-search-forward evil-visualstar/begin-search-backward))
    :config
    )

  (use-package evil-collection
    :after evil
    ;;mbk :straight t
    :defer 1
    :config
    (evil-collection-init)
    (message "evil-collection-init executed")
    (setq evil-collection-setup-minibuffer t)
    ;;mbk (setq evil-collection-mode-list t)
    )

  (use-package evil-args
    :defer 2
    :general
    (:keymaps 'evil-inner-text-objects-map
              "a" 'evil-inner-arg)
    (:keymaps 'evil-outer-text-objects-map
              "a" 'evil-outer-arg)
      )

  (use-package outshine
    :defer 2
    ;;mbk :straight t
    :hook ((prog-mode . outshine-mode)
           )
    :config
    ;; Narrowing now works within the headline rather than requiring to be on it
    (advice-add 'outshine-narrow-to-subtree :before
                (lambda (&rest args) (unless (outline-on-heading-p t)
                                       (outline-previous-visible-heading 1))))
;;mbk    :general
;;mbk    (:keymaps 'outline-minor-mode-map
;;mbk              "M-RET" 'outshine-insert-heading
;;mbk              "S-M-RET" 'outshine-insert-subheading
;;mbk              "<backtab>" 'outshine-cycle-buffer)
    )

  (use-package evil-lion
    :defer 1
    :after evil
    :config
    (evil-lion-mode)
    )

  (use-package which-key
    :defer 1
    :config
    (which-key-mode +1))

  (use-package avy
    :config
    (setq avy-timeout-seconds 0.35)
    (setq avy-background t))

  ;; Application Keybindings
  (tyrant-def
   :keymaps 'override
   "a"  '(:ignore t :which-key "Applications")
   "ad" 'dired-jump
   "ae" 'eshell
   "ar" 'ranger
   "aw" 'wttrin
   )
  ;; Buffer Keybindings
  (tyrant-def
    :keymaps 'override

   "b"  '(:ignore t :which-key "Buffers")
   ;;"bb" 'helm-mini
   ;;"bc" 'cpm/copy-whole-buffer-to-clipboard
   "bD" 'kill-buffer-and-window
   ;;"bd" 'cpm/kill-this-buffer
   "be" 'erase-buffer
   ;; "bf" 'cpm/browse-file-directory
   ;;"bj" 'cpm/jump-in-buffer
   "bk" 'evil-delete-buffer
   "bK" 'crux-kill-other-buffers
   "bl" 'display-line-numbers-mode
   ;;"bN" 'cpm/new-buffer-new-frame
   "bo" 'ivy-switch-buffer-other-window
   "br" 'revert-buffer
   "bs" 'counsel-switch-buffer
   "bR" 'crux-rename-buffer-and-file
   "bt" 'open-dir-in-iterm
   )
 ;; File Keybindings
  (tyrant-def
    :keymaps 'override

    "f"  '(:ignore t :which-key "Files")
    "ff" 'counsel-find-files
    "fl" 'counsel-locate
    "fo" 'crux-open-with
    "fs" 'save-buffer
    "fr" 'counsel-recentf
    "fy" '(cpm/show-and-copy-buffer-filename :which-key "show/copy")
    )

 ;; Search Keybindings
  (tyrant-def
    :keymaps 'override

    "s"  '(:ignore t :which-key "Search")
    "sa" 'evil-avy-goto-char-timer
    "sw" 'evil-avy-goto-word-or-subword-1
   )

 ;; Outline minor mode
;;mbk   (tyrant-def
;;mbk     :keymaps 'override
;;mbk
;;mbk     "n"  '(:ignore t :which-key "Narrow")
;;mbk     ;; Narrowing
;;mbk     "nn" '#outshine-narrow-to-subtree
;;mbk     "nw" '#widen
;;mbk
;;mbk     ;; Structural edits (use the keys defined by evil-collection-outline)
;;mbk    )
;;mbk    (tyrant-def
;;mbk     :keymaps 'outline-minor-mode-map
;;mbk     :states '(normal visual motion)
;;mbk     "gh" 'outline-up-heading
;;mbk     "gj" 'outline-forward-same-level
;;mbk     "gk" 'outline-backward-same-level
;;mbk     "gl" 'outline-next-visible-heading ;; also on ']]' (evil-collection-outline)
;;mbk     "gu" 'outline-previous-visible-heading ;; also on '[[' (evil-collection-outline)
;;mbk     )
  )


(setq-default display-line-numbers "relative")
(setq straight-cache-autoloads t)
(setq straight-use-package-by-default t)
(setq use-package-verbose t)
(setq evil-want-keybinding nil)
(setq evil-want-integration nil)
(defvar outline-minor-mode-prefix "\M-#")

(add-hook 'radian-after-init-hook #'radian-local--after-init)
