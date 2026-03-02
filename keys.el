;; ============================================================
;; KEYS — global keybindings (safe, layout-independent)
;; ============================================================


;; ============================================================
;; BUFFER NAVIGATION — beginning / end of buffer
;; Replacements for M-< and M->
;; ============================================================

(global-set-key (kbd "M-[") #'beginning-of-buffer)
(global-set-key (kbd "M-]") #'end-of-buffer)
(global-set-key (kbd "C-x C-b") 'ibuffer)


;; ============================================================
;; TERMINAL
;; ============================================================

;; Open vterm quickly
(global-set-key (kbd "C-c t") #'vterm)


;; ============================================================
;; WINDOWS
;; ============================================================

;; Swap window states
(global-set-key (kbd "C-c w s") #'window-swap-states)
