(setq desktop-save-mode nil)
(setq desktop-load-locked-desktop t) 

;; HARD DISABLE desktop/session restore
(desktop-save-mode 1)
(setq desktop-load-locked-desktop t)

;; ============================
;; Version control
;; ============================
(autoload 'magit-status "magit" nil t)

(load (locate-user-emacs-file "defaults.el") 'noerror 'nomessage)
(load (locate-user-emacs-file "keys.el") 'noerror 'nomessage)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'system)
(require 'packages)
(require 'line-numbers)
(require 'org-core)
(require 'org-capture)
(require 'org-agenda-config)
(require 'org-utils)
(require 'ui)
(require 'devotional)
(require 'pdf)
(require 'history)
(require 'history)
(setq recentf-save-file (expand-file-name "recentf" user-emacs-directory))
(setq recentf-max-saved-items 50)
(recentf-mode 1)
(recentf-load-list)  ;; <--- TO JEST TA KLUCZOWA LINIA (Wczytaj listę z dysku)

;; Zapisuj listę na dysk co 30 sekund i przy zamykaniu
(run-at-time nil 30 'recentf-save-list)
(add-hook 'kill-emacs-hook 'recentf-save-list)

(require 'nix)
(require 'javascript)
(require 'buffer-macros)
(require 'domowe)

;; ============================
;; Dashboard — Modlitwa
;; ============================

(defun my/dashboard-modlitwa (_size)
  (insert "\n")
  (insert (propertize "Modlitwa\n" 'face 'dashboard-heading))
  (insert "\n")
  (dolist (item '(("Dzień" . my/rytm-dnia-dzis)
                  ("Medytacja" . my/create-meditation-file)
                  ("Różaniec" . my/create-rozaniec-file)
                  ("Rachunek" . my/create-examen-file)
                  ("Noc" . my/create-night-prayer-file)
                  ("Skrót" . my/create-skrotka-file)
                  ("Sobota" . my/create-sobota-file)))
    (let ((name (car item))
          (f (cdr item)))
      (insert-text-button
       (format " [%s] " name)
       'action `(lambda (_) (,f)) ;; Ten przecinek tutaj to "magia", która wkleja funkcję na stałe
       'follow-link t))
    (insert "  "))
  (insert "\n"))

(defun my/dashboard-dom (_size)
  (insert "\n")
  (insert (propertize "Logistyka\n" 'face 'dashboard-heading))
  (insert "\n")
  (insert-text-button
   " [Zadania Domowe] "
   'action (lambda (_) (my/dzien-modlitwy-jeden-plik))
   'follow-link t)
  (insert "\n"))

(use-package dashboard
  :ensure t 
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq initial-scratch-message nil)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;; Jeśli nie masz tego pliku, Emacs użyje domyślnego logo:
  (setq dashboard-startup-banner "~/.config/emacs/images/dtmacs-logo.png")
  (setq dashboard-center-content nil)
  (setq dashboard-items '((modlitwa)
			  (dom)
                          (recents . 15)
                          (agenda . 5)
                          (bookmarks . 3)
                          (projects . 3)))
  :config
  ;; Rejestracja Twojej sekcji w silniku Dashboardu
  (add-to-list 'dashboard-item-generators '(modlitwa . my/dashboard-modlitwa))
  (add-to-list 'dashboard-item-generators '(dom . my/dashboard-dom))
  (dashboard-setup-startup-hook))
;; ============================
;; Launcher
;; ============================

(defun my/launcher ()
  "Prosty launcher Emacsa."
  (interactive)
  (let ((choice
         (completing-read
          "Launcher: "
          '("dashboard"
            "agenda"
	    "dzien"
            "rytmdnia"
            "medytacja"
            "rozaniec"
            "rachunek"
            "noc"
            "vterm"
            "dired"
            "mapa"))))
    (pcase choice
      ("dashboard" (dashboard-open))
      ("agenda" (org-agenda nil "a"))
      ("rytmdnia" (my/rytm-dnia-dzis))
      ("dzien" (my/dzien-modlitwy-jeden-plik))
      ("medytacja" (my/create-meditation-file))
      ("rozaniec" (my/create-rozaniec-file))
      ("rachunek" (my/create-examen-file))
      ("noc" (my/create-night-prayer-file))
      ("vterm" (vterm))
      ("dired" (dired "~"))
      ("mapa" (dired "~/mapa")))))

(global-set-key (kbd "C-c SPC") #'my/launcher)

;; Jeśli Dashboard zniknął, to go stwórz i wyświetl przy starcie
(add-hook 'after-init-hook (lambda ()
                             (dashboard-refresh-buffer)
                             (switch-to-buffer "*dashboard*")))
