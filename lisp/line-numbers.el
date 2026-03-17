;; ============================
;; Line numbers
;; ============================

(setq display-line-numbers-type 'relative)

(add-hook 'prog-mode-hook
          (lambda ()
            (display-line-numbers-mode 1)))

(add-hook 'vterm-mode-hook
          (lambda ()
            (display-line-numbers-mode 0)))

(add-hook 'org-mode-hook
          (lambda ()
            (setq-local display-line-numbers nil)))

(provide 'line-numbers)
