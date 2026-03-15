;; ============================
;; Nix
;; ============================

(defun nix-format-buffer ()
  "Format current buffer using alejandra."
  (interactive)
  (when (eq major-mode 'nix-mode)
    (shell-command-on-region (point-min) (point-max) "alejandra" (current-buffer) t)))

(add-hook 'nix-mode-hook #'flymake-mode)

(provide 'nix)
