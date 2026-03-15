(defvar n nil)

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
(require 'buffer-macros)

;; ============================
;; History / recent files
;; ============================
(savehist-mode 1)
(setq history-length 1000)
(recentf-mode 1)
(setq recentf-max-saved-items 300)

;; ============================
;; Nix
;; ============================
(defun nix-format-buffer ()
  "Format current buffer using alejandra."
  (interactive)
  (when (eq major-mode 'nix-mode)
    (shell-command-on-region (point-min) (point-max) "alejandra" (current-buffer) t)))

(add-hook 'nix-mode-hook #'flymake-mode)

;; ============================
;; JS
;; ============================
(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js\\'"  . js2-mode))
(add-to-list 'auto-mode-alist '("\\.mjs\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.cjs\\'" . js2-mode))
(setq js2-basic-offset 2
      js-indent-level 2)
(add-hook 'js2-mode-hook #'flymake-mode)

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

;; ============================
;; Line numbers
;; ============================
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook (lambda () (display-line-numbers-mode 1)))
(add-hook 'vterm-mode-hook (lambda () (display-line-numbers-mode 0)))
(add-hook 'org-mode-hook (lambda () (setq-local display-line-numbers nil)))

;; ============================
;; Org
;; ============================
(require 'org)
(require 'org-capture)
(require 'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(setq org-capture-templates
      '(("m" "Medytacja" plain (function my/create-meditation-file) nil :immediate-finish t)
        ("r" "Różaniec" plain (function my/create-rozaniec-file) nil :immediate-finish t)
        ("e" "Rachunek dnia" plain (function my/create-examen-file) nil :immediate-finish t)
        ("n" "Modlitwa nocna" plain (function my/create-night-prayer-file) nil :immediate-finish t)
        ("s" "Skrótacja" plain (function my/create-skrotka-file) nil :immediate-finish t)
        ("p" "Pierwsza sobota" plain (function my/create-sobota-file) nil :immediate-finish t)))

(setq org-agenda-files '("~/mapa/sesja.org" "~/mapa/plan.org" "~/mapa/biblioteka.org"))
(setq org-default-notes-file "~/mapa/sesja.org")
(setq org-adapt-indentation t
      org-startup-indented t)

(add-to-list 'org-agenda-custom-commands '("r" "Czytam teraz (książki)" todo "READING"))
(add-to-list 'org-agenda-custom-commands '("b" "Przeczytane (książki)" todo "DONE"))

(defun my/org-open-file-create-if-missing (orig-fun &rest args)
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

;; ============================
;; UI
;; ============================

(set-face-attribute 'default nil :font "JetBrains Mono" :height 120)

;; ============================
;; Dashboard — Modlitwa (DT style)
;; ============================

(defun my/dashboard-modlitwa ()
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
    (insert-text-button
     (car item)
     'action (lambda (_) (funcall (cdr item)))
     'follow-link t)
    (insert "\n")))

(use-package dashboard
  :ensure t 
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq initial-scratch-message nil)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  (setq dashboard-startup-banner "~/.config/emacs/images/dtmacs-logo.png")
  (setq dashboard-center-content nil)
  (setq dashboard-items '((recents . 15)
                          (agenda . 5)
                          (bookmarks . 3)
                          (projects . 3)))
  :custom 
  (dashboard-modify-heading-icons
   '((recents . "file-text")
     (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))
;; ============================
;; UI extras
;; ============================

(setq display-buffer-alist
      '(("^\\(\\*.*\\*\\|Dashboard\\)$"
         (display-buffer-no-window)
         (allow-no-window . t))))

(setq dired-use-ls-dired t
      dired-listing-switches "-alh --group-directories-first --color=auto")

(load-theme 'wombat t)

(require 'ido)
(ido-mode 1)
(setq ido-enable-flex-matching t
      ido-everywhere t)

(require 'org-roam)
(setq org-roam-directory (expand-file-name "~/org/roam"))
(org-roam-db-autosync-mode)

(with-eval-after-load 'dired
  (setq dired-use-ido nil))

(custom-set-variables
 '(package-selected-packages
   '(iedit multiple-cursors nix-mode persp-mode vterm)))
(custom-set-faces)

;; ============================
;; System clipboard integration
;; ============================
(setq select-enable-clipboard t)
(setq select-enable-primary t)

(defun my/menu-dnia ()
  "Menu dnia."
  (interactive)
  (let ((choice
         (read-key
          (propertize
           "Dzień: [D] dzień modlitwy [d] rytm  [m] medytacja  [r] różaniec  [e] rachunek  [n] noc  [s] skrót  [p] sobota  [q] wyjście"
           'face 'minibuffer-prompt))))
    (pcase choice
      (?D (my/dzien-modlitwy-jeden-plik))
      (?d (my/rytm-dnia-dzis))
      (?m (my/create-meditation-file))
      (?r (my/create-rozaniec-file))
      (?e (my/create-examen-file))
      (?n (my/create-night-prayer-file))
      (?s (my/create-skrotka-file))
      (?p (my/create-sobota-file))
      (?q (message "Menu zamknięte")))))

(global-set-key (kbd "C-c d") #'my/menu-dnia)

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
      ("medytacja" (my/create-meditation-file))
      ("rozaniec" (my/create-rozaniec-file))
      ("rachunek" (my/create-examen-file))
      ("noc" (my/create-night-prayer-file))
      ("vterm" (vterm))
      ("dired" (dired "~"))
      ("mapa" (dired "~/mapa")))))

(global-set-key (kbd "C-c SPC") #'my/launcher)

;; ============================
;; Devotional files (EU date)
;; ============================

;; ============================
;; Tajemnice różańca
;; ============================

(defvar my/rozaniec-tajemnice
  '(("radosne"
     "Zwiastowanie"
     "Nawiedzenie św. Elżbiety"
     "Narodzenie Jezusa"
     "Ofiarowanie Jezusa w świątyni"
     "Znalezienie Jezusa w świątyni")

    ("swiatla"
     "Chrzest Jezusa w Jordanie"
     "Cud w Kanie Galilejskiej"
     "Głoszenie Królestwa Bożego"
     "Przemienienie na górze Tabor"
     "Ustanowienie Eucharystii")

    ("bolesne"
     "Modlitwa w Ogrójcu"
     "Biczowanie"
     "Cierniem ukoronowanie"
     "Droga krzyżowa"
     "Śmierć na krzyżu")

    ("chwalebne"
     "Zmartwychwstanie"
     "Wniebowstąpienie"
     "Zesłanie Ducha Świętego"
     "Wniebowzięcie Maryi"
     "Ukoronowanie Maryi")))
;; ============================
;; Tajemnica dnia (różaniec)
;; ============================

(defun my/rozaniec-dzis ()
  "Zwraca tajemnicę różańca dla dzisiejszego dnia."
  (pcase (format-time-string "%u")
    ("1" "radosne")    ;; poniedziałek
    ("2" "bolesne")    ;; wtorek
    ("3" "chwalebne")  ;; środa
    ("4" "swiatla")    ;; czwartek
    ("5" "bolesne")    ;; piątek
    ("6" "radosne")    ;; sobota
    ("7" "chwalebne"))) ;; niedziela

(defun my--eu-date () (format-time-string "%d-%m-%Y"))

(defun my--choose-mystery ()
  (let* ((today (my/rozaniec-dzis)))
    (completing-read
     (format "Tajemnica (RET = %s): " today)
     '("radosne" "bolesne" "chwalebne" "swiatla")
     nil t nil nil today)))

(defun my/create-meditation-file ()
  (let* ((dir "~/mapa/Modlitwy/medytacja/")
         (date (my--eu-date))
         (file (expand-file-name (concat date ".org") dir)))
    (unless (file-exists-p dir)
      (make-directory dir t))
    (unless (file-exists-p file)
      (with-temp-buffer
        (insert "#+title: Medytacja\n")
        (insert "#+date: " date "\n\n")
        (insert "Siglum:\n\n")

        (insert "*** SPOJRZENIE\n")
        (insert "Scena Ewangelii:\n")
        (insert "Osoby:\n")
        (insert "Słowo klucz / oś fragmentu:\n")
        (insert "Słowo które zatrzymuje:\n\n")

        (insert "*** JEZUS\n")
        (insert "Jaki jest:\n")
        (insert "Jego serce:\n")
        (insert "Jego postawa:\n")
        (insert "Jego obecność:\n\n")

        (insert "*** JA PRZY NIM\n")
        (insert "Jak jestem przy Nim:\n")
        (insert "Co się we mnie porusza:\n")
        (insert "Co przyciąga:\n")
        (insert "Co opiera się:\n")
        (insert "Czego pragnę przy Nim:\n\n")

        (insert "*** SŁOWO W SERCU\n")
        (insert "Zdanie:\n")
        (insert "Powolne powracanie:\n\n")

        (insert "*** TRWANIE\n")
        (insert "Cicha obecność razem:\n")

        (write-file file)))
    (find-file file)))

;; ============================
;; Rachunek dnia
;; ============================

(defun my/create-examen-file ()
  (let* ((dir "~/mapa/Modlitwy/rachunek/")
         (date (my--eu-date))
         (file (expand-file-name (concat date ".org") dir)))
    (unless (file-exists-p dir)
      (make-directory dir t))
    (unless (file-exists-p file)
      (with-temp-buffer
        (insert "#+title: Rachunek dnia\n")
        (insert "#+date: " date "\n\n")

        (insert "*** SPOJRZENIE NA DZIEŃ\n")
	(insert "Za co dziękuję:\n")
        (insert "Gdzie byłem:\n")
        (insert "Wydarzenia:\n")
        (insert "Spotkania:\n")
        (insert "Słowo klucz dnia:\n")
        (insert "Moment który zatrzymuje:\n\n")

        (insert "*** JEZUS W MOIM DNIU\n")
        (insert "Gdzie był blisko:\n")
        (insert "Jego serce wobec mnie:\n")
        (insert "Jego postawa:\n")
        (insert "Jego obecność:\n\n")

        (insert "*** JA PRZY NIM W TYM DNIU\n")
        (insert "Jak byłem przy Nim:\n")
        (insert "Co się we mnie poruszało:\n")
        (insert "Co przyciągało:\n")
        (insert "Co opierało się:\n")
        (insert "Czego pragnę dalej:\n\n")

        (insert "*** SŁOWO DNIA\n")
        (insert "Zdanie:\n")
        (insert "Powracanie:\n\n")

        (insert "*** TRWANIE\n")
        (insert "Oddanie dnia:\n")

        (write-file file)))
    (find-file file)))

;; ============================
;; Modlitwa nocna
;; ============================

(defun my/create-night-prayer-file ()
  (let* ((dir "~/mapa/Modlitwy/noc/")
         (date (my--eu-date))
         (file (expand-file-name (concat date ".org") dir)))
    (unless (file-exists-p dir)
      (make-directory dir t))
    (unless (file-exists-p file)
      (with-temp-buffer
        (insert "#+title: Modlitwa nocna\n")
        (insert "#+date: " date "\n\n")

        (insert "*** WEJŚCIE\n")
        (insert "Uciszenie:\n")
        (insert "Obecność Boga:\n\n")

        (insert "*** I. MEDYTACJA\n\n")
        (insert "Siglum:\n\n")

        (insert "**** SPOJRZENIE\n")
        (insert "Scena Ewangelii:\n")
        (insert "Osoby:\n")
        (insert "Słowo klucz / oś fragmentu:\n")
        (insert "Słowo które zatrzymuje:\n\n")

        (insert "**** JEZUS\n")
        (insert "Jaki jest:\n")
        (insert "Jego serce:\n")
        (insert "Jego postawa:\n")
        (insert "Jego obecność:\n\n")

        (insert "**** JA PRZY NIM\n")
        (insert "Jak jestem przy Nim:\n")
        (insert "Co się we mnie porusza:\n")
        (insert "Co przyciąga:\n")
        (insert "Co opiera się:\n")
        (insert "Czego pragnę przy Nim:\n\n")

        (insert "**** SŁOWO W SERCU\n")
        (insert "Zdanie:\n")
        (insert "Powolne powracanie:\n\n")

        (insert "**** TRWANIE\n")
        (insert "Cicha obecność razem:\n\n")

        (insert "*** II. MODLITWA\n\n")

        (insert "**** RÓŻANIEC\n\n")

        (insert "***** CZĘŚĆ RADOSNA\n")
        (insert "Temat:\n\n")
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "***** CZĘŚĆ ŚWIATŁA\n")
        (insert "Temat:\n\n")
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "***** CZĘŚĆ BOLESNA\n")
        (insert "Temat:\n\n")
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "***** CZĘŚĆ CHWALEBNA\n")
        (insert "Temat:\n\n")
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "**** LITANIA\n")
        (insert "Nazwa:\n")
        (insert "Intencja:\n")
        (insert "Owoc:\n\n")

        (insert "**** INNA MODLITWA\n")
        (insert "Nazwa:\n")
        (insert "Intencja:\n")
        (insert "Owoc:\n\n")

        (insert "*** III. TRWANIE\n")
        (insert "Cisza przy Bogu:\n\n")

        (insert "*** ODDANIE NOCY\n")
        (insert "Sen w Jego obecności:\n")

        (write-file file)))
    (find-file file)))

(defun my/create-skrotka-file ()
  (let* ((dir "~/mapa/Modlitwy/skrotacja/")
         (date (my--eu-date))
         (file (expand-file-name (concat date ".org") dir)))
    (unless (file-exists-p file)
      (with-temp-buffer
        (insert "#+title: Skrótacja\n")
        (insert "#+date: " date "\n\n")
        (write-file file)))
    (find-file file)))

(defun my/create-sobota-file ()
  (let* ((m (my--choose-mystery))
         (dir (expand-file-name m "~/mapa/Modlitwy/sobota/"))
         (date (my--eu-date))
         (file (expand-file-name (concat date ".org") dir)))
    (unless (file-exists-p file)
      (with-temp-buffer
        (insert "#+title: Pierwsza sobota – " m "\n")
        (insert "#+date: " date "\n\n")
        (write-file file)))
    (find-file file)))

(defun my/create-rozaniec-file ()
  (let* ((m (my--choose-mystery))
         (tajemnice (cdr (assoc m my/rozaniec-tajemnice)))
         (dir (expand-file-name m "~/mapa/Modlitwy/różaniec/"))
         (date (my--eu-date))
         (file (expand-file-name (concat date ".org") dir)))

    (unless (file-exists-p dir)
      (make-directory dir t))

    (unless (file-exists-p file)
      (with-temp-buffer
        (insert "#+title: Różaniec – " m "\n")
        (insert "#+date: " date "\n\n")

        (insert "* Intencja\n\n")

        (dolist (myst tajemnice)
          (insert "** " myst "\n")
          (insert "Intencja:\n")
          (insert "Owoc:\n\n"))

        (write-file file)))

    (find-file file)

    ;; automatyczne zwinięcie
    (org-overview)))

(defun my/dzien-modlitwy-jeden-plik ()
  "Utwórz jeden plik z całym dniem modlitwy."
  (interactive)

  (let* ((dir "~/mapa/Modlitwy/dni/")
         (date (my--eu-date))
         (file (expand-file-name (concat date ".org") dir))
         (m (my--choose-mystery))
         (tajemnice (cdr (assoc m my/rozaniec-tajemnice))))

    (unless (file-exists-p dir)
      (make-directory dir t))

    (unless (file-exists-p file)
      (with-temp-buffer

        (insert "#+title: Dzień modlitwy\n")
        (insert "#+date: " date "\n\n")

        ;; ======================
        ;; MEDYTACJA
        ;; ======================

        (insert "* Medytacja\n\n")
        (insert "Siglum:\n\n")

        (insert "** SPOJRZENIE\n")
        (insert "Scena Ewangelii:\n")
        (insert "Osoby:\n")
	(insert "Słowo klucz:\n")
        (insert "Słowo które zatrzymuje:\n\n")

        (insert "** JEZUS\n")
        (insert "Jaki jest:\n")
        (insert "Jego serce:\n")
	(insert "Jego postawa:\n")
        (insert "Jego obecność:\n\n")

        (insert "** JA PRZY NIM\n")
        (insert "Co się we mnie porusza:\n")
	(insert "Co przyciąga?:\n")
	(insert "Co się opiera?:\n")
	(insert "Czego pragnę przy Nim?:\n\n")

	(insert "** SŁOWO W SERCU\n")
	(insert "Zdanie:\n")
	(insert "Powolne powracanie:\n\n")

	(insert "TRWANIE\n")
	(insert "Cicha obecność razem:\n\n")

        ;; ======================
        ;; RÓŻANIEC
        ;; ======================

        (insert "* Różaniec – " m "\n\n")

        (insert "** Intencja\n\n")

        (dolist (myst tajemnice)
          (insert "*** " myst "\n")
          (insert "Intencja:\n")
          (insert "Owoc:\n\n"))

        ;; ======================
        ;; DZIEŃ
        ;; ======================

        (insert "* Dzień\n\n")
        (insert "Słowo które noszę przez dzień:\n\n")

        ;; ======================
        ;; RACHUNEK DNIA
        ;; ======================

        (insert "* Rachunek dnia\n\n")
        
        (insert "** SPOJRZENIE NA DZIEŃ\n")
	(insert "Za co dziękuję:\n")
        (insert "Gdzie byłem:\n")
        (insert "Wydarzenia:\n")
        (insert "Spotkania:\n")
        (insert "Słowo klucz dnia:\n")
        (insert "Moment który zatrzymuje:\n\n")

        (insert "*** JEZUS W MOIM DNIU\n")
        (insert "Gdzie był blisko:\n")
        (insert "Jego serce wobec mnie:\n")
        (insert "Jego postawa:\n")
        (insert "Jego obecność:\n\n")

        (insert "*** JA PRZY NIM W TYM DNIU\n")
        (insert "Jak byłem przy Nim:\n")
        (insert "Co się we mnie poruszało:\n")
        (insert "Co przyciągało:\n")
        (insert "Co opierało się:\n")
        (insert "Czego pragnę dalej:\n\n")

        (insert "*** SŁOWO DNIA\n")
        (insert "Zdanie:\n")
        (insert "Powracanie:\n\n")

        (insert "*** TRWANIE\n")
        (insert "Oddanie dnia:\n")

        
        ;; ======================
        ;; NOC
        ;; ======================

        (insert "* Modlitwa nocna\n\n")
       
 

        (insert "*** WEJŚCIE\n")
        (insert "Uciszenie:\n")
        (insert "Obecność Boga:\n\n")

        (insert "*** I. MEDYTACJA\n\n")
        (insert "Siglum:\n\n")

        (insert "**** SPOJRZENIE\n")
        (insert "Scena Ewangelii:\n")
        (insert "Osoby:\n")
        (insert "Słowo klucz / oś fragmentu:\n")
        (insert "Słowo które zatrzymuje:\n\n")

        (insert "**** JEZUS\n")
        (insert "Jaki jest:\n")
        (insert "Jego serce:\n")
        (insert "Jego postawa:\n")
        (insert "Jego obecność:\n\n")

        (insert "**** JA PRZY NIM\n")
        (insert "Jak jestem przy Nim:\n")
        (insert "Co się we mnie porusza:\n")
        (insert "Co przyciąga:\n")
        (insert "Co opiera się:\n")
        (insert "Czego pragnę przy Nim:\n\n")

        (insert "**** SŁOWO W SERCU\n")
        (insert "Zdanie:\n")
        (insert "Powolne powracanie:\n\n")

        (insert "**** TRWANIE\n")
        (insert "Cicha obecność razem:\n\n")

        (insert "*** II. MODLITWA\n\n")

        (insert "**** RÓŻANIEC\n\n")

        (insert "***** CZĘŚĆ RADOSNA\n")
        (insert "Temat:\n\n")
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "***** CZĘŚĆ ŚWIATŁA\n")
        (insert "Temat:\n\n")
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "***** CZĘŚĆ BOLESNA\n")
        (insert "Temat:\n\n")
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "***** CZĘŚĆ CHWALEBNA\n")
        (insert "Temat:\n\n")
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "**** LITANIA\n")
        (insert "Nazwa:\n")
        (insert "Intencja:\n")
        (insert "Owoc:\n\n")

        (insert "**** INNA MODLITWA\n")
        (insert "Nazwa:\n")
        (insert "Intencja:\n")
        (insert "Owoc:\n\n")

        (insert "*** III. TRWANIE\n")
        (insert "Cisza przy Bogu:\n\n")

        (insert "*** ODDANIE NOCY\n")
        (insert "Sen w Jego obecności:\n")

       
	
        (write-file file)))

    (find-file file)
    (org-overview)))

(defun domowe-nowy-dzien ()
  "Utwórz nowy plik z zadaniami domowymi na dziś."
  (interactive)
  (let* ((dir "~/org/domowe/")
         (file (concat dir (format-time-string "%d-%m-%Y.org")))
         (template "~/.emacs.d/templates/domowe-dzien.org"))
    (unless (file-exists-p dir) (make-directory dir t))
    (unless (file-exists-p file) (copy-file template file))
    (find-file file)))


(defun my/rytm-dnia-dzis ()
  "Otwórz lub utwórz plik rytmu dnia na dziś."
  (interactive)
  (let* ((dir "~/mapa/Modlitwy/rytm-dnia/dni/")
         (date (format-time-string "%d-%m-%Y %A"))
         (file (expand-file-name (format-time-string "%d-%m-%Y.org") dir))
         (template "~/mapa/Modlitwy/rytm-dnia/szablon-dnia.org"))
    (unless (file-exists-p dir) (make-directory dir t))
    (unless (file-exists-p file)
      (copy-file template file)
      (with-temp-buffer
        (insert "* " date "\n\n")
        (append-to-file (point-min) (point-max) file)))
    (find-file file)))
