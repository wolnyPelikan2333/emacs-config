;; ============================
;; Org utilities
;; ============================

(defun my/org-open-file-create-if-missing (orig-fun &rest args)
  "Jeśli link do pliku w Org prowadzi do nieistniejącego pliku,
utwórz go automatycznie z podstawowym nagłówkiem."
  (let ((context (org-element-context)))
    (when (and (eq (org-element-type context) 'link)
               (string= (org-element-property :type context) "file"))
      (let* ((path (org-element-property :path context))
             (full (expand-file-name path)))
        (unless (file-exists-p full)
          (make-directory (file-name-directory full) t)
          (with-temp-file full
            (insert (format "#+title: %s\n\n" (file-name-base full))))))))
  (apply orig-fun args))

(advice-add 'org-open-at-point :around #'my/org-open-file-create-if-missing)

(provide 'org-utils)
