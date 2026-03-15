(require 'package)

(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")
        ("org" . "https://orgmode.org/elpa/")))

(package-initialize)

(defvar my/packages
  '(use-package
    which-key
    vterm
    nix-mode
    multiple-cursors
    js2-mode
    json-mode
    pdf-tools))

(unless package-archive-contents
  (package-refresh-contents))

(dolist (pkg my/packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))

(require 'yasnippet)
(yas-global-mode 1)

(provide 'packages)
