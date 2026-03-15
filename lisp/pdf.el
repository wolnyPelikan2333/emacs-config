;; ============================
;; PDF (pdf-tools)
;; ============================
(require 'pdf-tools)
(pdf-tools-install)
(setq-default pdf-view-display-size 'fit-width)

;; OCR command for current PDF
(defun my/pdf-ocr-current ()
  "Run OCR on current PDF using ocrmypdf and open result."
  (interactive)
  (unless (derived-mode-p 'pdf-view-mode)
    (user-error "Not in a PDF buffer"))
  (let* ((src (buffer-file-name))
         (dst (concat (file-name-sans-extension src) "_ocr.pdf"))
         (cmd (format "ocrmypdf --skip-text --optimize 3 %s %s"
                      (shell-quote-argument src)
                      (shell-quote-argument dst))))
    (unless (executable-find "ocrmypdf")
      (user-error "ocrmypdf not found in PATH"))
    (message "Running OCR…")
    (if (= 0 (shell-command cmd))
        (progn (find-file dst)
               (message "OCR done: %s" dst))
      (user-error "OCR failed"))))

(with-eval-after-load 'pdf-view
  (define-key pdf-view-mode-map (kbd "i") #'my/pdf-annot-to-org)
  (define-key pdf-view-mode-map (kbd "O") #'my/pdf-ocr-current))

;; ============================
;; PDF → Org per-book
;; ============================
(defvar my/pdf-notes-dir "~/mapa/pdf-notes/")

(defun my/pdf-annot-to-org ()
  "Save PDF highlight into per-book Org file."
  (interactive)
  (unless (derived-mode-p 'pdf-view-mode)
    (user-error "Not in PDF"))
  (let* ((text (pdf-view-active-region-text))
         (page (pdf-view-current-page))
         (pdf-path (buffer-file-name))
         (title (file-name-base pdf-path))
         (org-file (expand-file-name (concat title ".org") my/pdf-notes-dir))
         (link (format "file:%s::%d" pdf-path page)))
    (with-current-buffer (find-file-noselect org-file)
      (goto-char (point-max))
      (unless (save-excursion
                (goto-char (point-min))
                (search-forward (concat "* " title) nil t))
        (insert (format "* %s\n" title)))
      (goto-char (point-min))
      (search-forward (concat "* " title))
      (unless (save-excursion
                (org-narrow-to-subtree)
                (goto-char (point-min))
                (search-forward (format "** Strona %d" page) nil t))
        (org-end-of-subtree t t)
        (insert (format "\n** Strona %d\n" page)))
      (org-narrow-to-subtree)
      (goto-char (point-min))
      (search-forward (format "** Strona %d" page))
      (org-end-of-subtree t t)
      (insert
       (format "\n*** Cytat\n:PROPERTIES:\n:SOURCE: %s\n:END:\n\n#+begin_quote\n%s\n#+end_quote\n"
               link text))
      (widen)
      (save-buffer))
    (message "Saved to %s" org-file)))

(provide 'pdf)
