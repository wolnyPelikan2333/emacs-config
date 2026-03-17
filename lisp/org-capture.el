(require 'org)

(global-set-key (kbd "C-c c") #'org-capture)

(setq org-capture-templates
      '(("m" "Medytacja" plain (function my/create-meditation-file) nil :immediate-finish t)
        ("r" "Różaniec" plain (function my/create-rozaniec-file) nil :immediate-finish t)
        ("e" "Rachunek dnia" plain (function my/create-examen-file) nil :immediate-finish t)
        ("n" "Modlitwa nocna" plain (function my/create-night-prayer-file) nil :immediate-finish t)
        ("s" "Skrótacja" plain (function my/create-skrotka-file) nil :immediate-finish t)
        ("p" "Pierwsza sobota" plain (function my/create-sobota-file) nil :immediate-finish t)))

(provide 'org-capture)
