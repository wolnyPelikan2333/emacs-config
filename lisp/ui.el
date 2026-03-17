;; ============================
;; UI
;; ============================

;; font
(set-face-attribute 'default nil :font "JetBrains Mono" :height 120)

;; theme
(load-theme 'wombat t)

;; ido
(require 'ido)
(ido-mode 1)

(setq ido-enable-flex-matching t
      ido-everywhere t)

;; display rules
(setq display-buffer-alist
      '(("^\\(\\*.*\\*\\|Dashboard\\)$"
         (display-buffer-no-window)
         (allow-no-window . t))))

;; dired
(setq dired-use-ls-dired t
      dired-listing-switches "-alh --group-directories-first --color=auto")

(with-eval-after-load 'dired
  (setq dired-use-ido nil))

;; clipboard
(setq select-enable-clipboard t
      select-enable-primary t)

(provide 'ui)
