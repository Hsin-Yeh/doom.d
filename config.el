;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Hsin-Yeh Wu"
      user-mail-address "thankyouyou06@gmail.com")

(defun tangle-init ()
  "If the current buffer is 'init.org' the code-blocks are
  tangled, and the tangled file is compiled."
  (interactive)
  (when (equal (buffer-file-name)
           (expand-file-name "~/.doom.d/config.org"))
    ;; Avoid running hooks when tangling.
    (let ((prog-mode-hook nil))
      (org-babel-tangle)
      (byte-compile-file "~/.doom.d/config.el"))))

(add-hook 'after-save-hook 'tangle-init)

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Source Code Pro" :size 16))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

(add-to-list 'default-frame-alist '(ns-appearance . dark))  ;;set the title bar dark

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

(setq org-directory "~/Documents/org/")

(after! org
  (setq org-agenda-start-day "+0d"
        org-archive-location (concat org-directory "archive/%s::")
        org-log-done 'time
        org-log-done 'note
        org-priority-regexp ".*?\\(\\[#\\([A-Z0-9]\\)\\] ?\\)" ;set this property to default of org.el. The tweek doom does would screw up the priority.
        org-todo-keywords
        '((sequence
           "TODO(t)"  ; A task that needs doing & is ready to do
           "NEXT(n)"  ; next todo
           "STRT(s)"  ; A task that is in progress
           "WAIT(w)"  ; Something external is holding up this task
           "HOLD(h)"  ; This task is paused/on hold because of me
           "|"
           "DONE(d)"  ; Task successfully completed
           "KILL(k)")) ; Task was cancelled, aborted or is no longer applicable
        org-todo-keyword-faces
        '(("STRT" . +org-todo-active)
          ("WAIT" . +org-todo-onhold)
          ("HOLD" . +org-todo-onhold)
          ("NEXT" . +org-todo-active)
          ("PROJ" . +org-todo-project)))
  (add-to-list 'org-modules 'org-habit t))

;; (setq org-priority-faces '((?A . (:foreground "red" :weight bold))
;;                            (?B . (:foreground "yellow"))
;;                            (?C . (:foreground "green"))))

(after! org
  (setq org-capture-templates
        '(("t" "Personal todo" entry
           (file +org-capture-todo-file )
           "* TODO %?\n%i\n%a" :prepend t)
          ("n" "Personal notes" entry
           (file +org-capture-notes-file )
           "* %u %?\n%i\n%a" :prepend t )
          ("j" "Journal" entry
           (file+olp+datetree +org-capture-journal-file)
           "* %U %?\n%i\n%a" :prepend t))))

(use-package org-bullets
  :custom
  (org-bullets-bullet-list '("◉" "○" "✸" "✿" "✜" "◆" "▶"))
  (org-ellipsis "⤵")
  :hook (org-mode . org-bullets-mode))

(org-super-agenda-mode)  ;enable org super agenda

(setq org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-include-deadlines nil
      org-agenda-include-diary t
      org-agenda-block-separator nil
      org-agenda-compact-blocks t
      org-agenda-start-with-log-mode t)

(setq org-agenda-custom-commands
      '(("z" "Super zaen view"
         ((agenda "" ((org-agenda-span 'day)
                      (org-super-agenda-groups
                       '((:name "Today"
                          :time-grid t
                          :date today
                          :todo "TODAY"
                          :scheduled today
                          :order 1)))))
          (alltodo "" ((org-agenda-overriding-header "")
                       (org-super-agenda-groups
                        '((:name "Next to do"
                           :todo "NEXT"
                           :order 1)
                          (:name "Important"
                           :tag "Important"
                           :priority "A"
                           :order 6)
                          (:name "Due Today"
                           :deadline today
                           :order 2)
                          (:name "Due Soon"
                           :deadline future
                           :order 8)
                          (:name "Overdue"
                           :deadline past
                           :face (:background "#7f1b19")
                           :order 7)
                          (:name "Assignments"
                           :tag "Assignment"
                           :order 10)
                          (:name "HGCAL/MAC"
                           :tag "MAC"
                           :tag "HGCAL"
                           :order 12)
                          (:name "EQ Detector"
                           :tag "EQ"
                           :order 13)
                          (:name "Emacs"
                           :tag "Emacs"
                           :order 15)
                          (:name "AnaBHEL"
                           :tag "AnaBHEL"
                           :order 14)
                          (:name "To read"
                           :tag "Read"
                           :order 30)
                          (:name "Waiting"
                           :todo "WAITING"
                           :order 20)
                          (:name "trivial"
                           :priority<= "C"
                           :tag ("Trivial" "Unimportant")
                           :todo ("SOMEDAY" )
                           :order 90)
                          (:discard
                           (:tag ("lesson" "meeting" "Chore" "Routine" "Daily")
                            :scheduled future))))))))))

(after! evil-org-agenda
  (setq org-super-agenda-header-map (copy-keymap evil-org-agenda-mode-map)))  ;overwrite org-super-agenda-header-map with evil-org-agenda-mode-map

;; "Visit the org agenda, in the current window or a SPLIT."
(defun air-pop-to-org-agenda (&optional split)
  (interactive "P")
  (org-agenda nil "z")
  (when (not split)
    (delete-other-windows)))

(global-set-key (kbd "<f3>") 'air-pop-to-org-agenda)

(after! company
  (set-company-backend! :derived 'prog-mode 'company-dabbrev 'company-yasnippet)
  (set-company-backend! 'python-mode 'company-dabbrev)
  (add-to-list 'company-backends '(company-files
                                   company-keywords
                                   company-capf
                                   company-dabbrev-code
                                   company-etags
                                   company-dabbrev)))
(setq company-dabbrev-char-regexp "\\sw\\|\\s_")
(push '("\\*Completions\\*"
        (display-buffer-use-some-window display-buffer-pop-up-window)
        (inhibit-same-window . t))
      display-buffer-alist)

(use-package dired-single
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer
    "K" 'dired-do-kill-lines))

;; set evil insert mode keybindings to emacs keybindings
(setq evil-insert-state-map (make-sparse-keymap))
(define-key evil-insert-state-map (kbd "<escape>") 'evil-normal-state)
(define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)

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
