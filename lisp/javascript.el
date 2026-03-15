;; ============================
;; JavaScript
;; ============================

(autoload 'js2-mode "js2-mode" nil t)

(add-to-list 'auto-mode-alist '("\\.js\\'"  . js2-mode))
(add-to-list 'auto-mode-alist '("\\.mjs\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.cjs\\'" . js2-mode))

(setq js2-basic-offset 2
      js-indent-level 2)

(add-hook 'js2-mode-hook #'flymake-mode)

(provide 'javascript)
