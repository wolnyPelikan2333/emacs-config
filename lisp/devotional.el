;; ============================
;; Devotional system
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
;; Tajemnica dnia
;; ============================

(defun my/rozaniec-dzis ()
  "Zwraca tajemnicę różańca dla dzisiejszego dnia."
  (pcase (format-time-string "%u")
    ("1" "radosne")
    ("2" "bolesne")
    ("3" "chwalebne")
    ("4" "swiatla")
    ("5" "bolesne")
    ("6" "radosne")
    ("7" "chwalebne")))


;; ============================
;; Data EU
;; ============================

(defun my--eu-date ()
  (format-time-string "%d-%m-%Y"))


;; ============================
;; Wybór tajemnicy
;; ============================

(defun my--choose-mystery ()
  (let* ((today (my/rozaniec-dzis)))
    (completing-read
     (format "Tajemnica (RET = %s): " today)
     '("radosne" "bolesne" "chwalebne" "swiatla")
     nil t nil nil today)))


;; ============================
;; Medytacja
;; ============================

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
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "***** CZĘŚĆ ŚWIATŁA\n")
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "***** CZĘŚĆ BOLESNA\n")
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "***** CZĘŚĆ CHWALEBNA\n")
        (dotimes (i 5)
          (insert (format "****** TAJEMNICA %d\nNazwa:\nIntencja:\nOwoc:\n\n" (1+ i))))

        (insert "*** III. TRWANIE\n")
        (insert "Cisza przy Bogu:\n\n")

        (insert "*** ODDANIE NOCY\n")
        (insert "Sen w Jego obecności:\n")

        (write-file file)))
    (find-file file)))


;; ============================
;; Skrótacja
;; ============================

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


;; ============================
;; Pierwsza sobota
;; ============================

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

;; ============================
;; Różaniec
;; ============================

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

    (org-overview)))

;; ============================
;; Jeden plik dnia modlitwy
;; ============================

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

        (insert "* Medytacja\n\n")
        (insert "Siglum:\n\n")
	(insert "** Spojrzenie\n")
	(insert "Scena Ewangelii:\n")
	(insert "Osoby:\n")
	(insert "Słowo klucz / oś fragmentu:\n")
	(insert "Słowo które zatrzymuje:\n\n")

	(insert "** Jezus\n")
	(insert "Jaki jest:\n")
	(insert "Jego serce:\n")
	(insert "Jego postawa:\n")
	(insert "Jego obecność:\n\n")

	(insert "** Ja przy Nim\n")
	(insert "Jak jestem przy Nim:\n")
	(insert "Co się we mnie porusza:\n")
	(insert "Co przyciąga:\n")
	(insert "Co opiera się:\n")
	(insert "Czego pragnę przy Nim:\n\n")

	(insert "** Słowo w sercu\n")
	(insert "Zdanie:\n")
	(insert "Powolne powracanie:\n\n")

	(insert "** Trwanie\n")
	(insert "Cicha obecność razem:\n\n")

        (insert "* Różaniec – " m "\n\n")

        (insert "** Intencja\n\n")

        (dolist (myst tajemnice)
          (insert "*** " myst "\n")
          (insert "Intencja:\n")
          (insert "Owoc:\n\n"))

        (insert "* Dzień\n\n")
        (insert "Słowo które noszę przez dzień:\n\n")

        (insert "* Rachunek dnia\n\n")
	(insert "** Spojrzenie na dzień\n")
	(insert "Za co dziękuję:\n")
	(insert "Wydarzenia:\n")
	(insert "Spotkania:\n\n")

	(insert "** Jezus w moim dniu\n")
	(insert "Gdzie był blisko:\n")
	(insert "Jego obecność:\n\n")

	(insert "** Ja przy Nim\n")
	(insert "Co się poruszało:\n\n")

        (insert "* Modlitwa nocna\n\n")
	(insert "** Wejście\n")
	(insert "Uciszenie:\n")
	(insert "Obecność Boga:\n\n")

	(insert "** Trwanie\n")
	(insert "Cisza przy Bogu:\n\n")

	(insert "** Oddanie nocy\n")
	(insert "Sen w Jego obecności:\n\n")

        (write-file file)))

    (find-file file)
    (org-overview)))

;; ============================
;; Rytm dnia
;; ============================

(defun my/rytm-dnia-dzis ()
  "Otwórz lub utwórz plik rytmu dnia na dziś."
  (interactive)
  (let* ((dir "~/mapa/Modlitwy/rytm-dnia/dni/")
         (date (format-time-string "%d-%m-%Y %A"))
         (file (expand-file-name (format-time-string "%d-%m-%Y.org") dir))
         (template "~/mapa/Modlitwy/rytm-dnia/szablon-dnia.org"))
    (unless (file-exists-p dir)
      (make-directory dir t))
    (unless (file-exists-p file)
      (copy-file template file)
      (with-temp-buffer
        (insert "* " date "\n\n")
        (append-to-file (point-min) (point-max) file)))
    (find-file file)))

(defun dashboard-insert-modlitwa (list-size)
  "Wstawia przyciski modlitwy do dashboardu."
  (dashboard-insert-section
   "Modlitwa:"
   nil
   (all-the-icons-faicon "book" :height 1.2 :v-adjust 0.0 :face 'dashboard-heading)
   "Modlitwa"
   nil
   (insert "\n    ")
   (widget-create 'item
                  :tag "[ Dzień ]"
                  :action (lambda (&rest _) (my/dzien-modlitwy-jeden-plik)))
   (insert "  ")
   (widget-create 'item
                  :tag "[ Noc ]"
                  :action (lambda (&rest _) (my/create-night-prayer-file)))
   (insert "\n")))

(provide 'devotional)
