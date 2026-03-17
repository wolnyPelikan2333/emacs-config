(require 'org-agenda)

(setq org-agenda-files
      '("~/mapa/sesja.org"
        "~/mapa/plan.org"
        "~/mapa/biblioteka.org"))

(add-to-list 'org-agenda-custom-commands
             '("r" "Czytam teraz (książki)" todo "READING"))

(add-to-list 'org-agenda-custom-commands
             '("b" "Przeczytane (książki)" todo "DONE"))

(provide 'org-agenda-config)
