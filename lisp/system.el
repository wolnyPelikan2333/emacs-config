;; ============================
;; File safety & recovery
;; ============================

(defvar my/emacs-backup-dir
  (expand-file-name "backups/" user-emacs-directory))

(unless (file-exists-p my/emacs-backup-dir)
  (make-directory my/emacs-backup-dir t))

(setq auto-save-default t
      auto-save-timeout 20
      auto-save-interval 200
      auto-save-file-name-transforms
      `((".*" ,my/emacs-backup-dir t)))

(setq make-backup-files t
      backup-directory-alist
      `(("." . ,my/emacs-backup-dir))
      version-control t
      kept-new-versions 10
      kept-old-versions 5
      delete-old-versions t)

(auto-save-visited-mode 1)
(setq auto-save-visited-interval 30)
(setq require-final-newline t)

(provide 'system)
