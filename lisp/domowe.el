;;==========================================
;; Domowe-nowy-dzień
;;===========================================

(defun domowe-nowy-dzien ()
  "Utwórz nowy plik z zadaniami domowymi na dziś."
  (interactive)
  (let* ((dir "~/org/domowe/")
         (file (concat dir (format-time-string "%d-%m-%Y.org")))
         (template "~/.emacs.d/templates/domowe-dzien.org"))
    (unless (file-exists-p dir) (make-directory dir t))
    (unless (file-exists-p file) (copy-file template file))
    (find-file file)))

(provide 'domowe)
