;; ============================================================
;; RECENT FILES — remember recently edited files
;; ============================================================

;; Keep a list of recently opened files for quick access
;; Usage: M-x recentf-open-files
(recentf-mode 1)


;; ============================================================
;; MINIBUFFER HISTORY — remember prompt inputs
;; ============================================================

;; Number of minibuffer history items to keep
(setq history-length 25)

;; Save minibuffer history across sessions
;; Enables M-p / M-n in most minibuffer prompts
(savehist-mode 1)


;; ============================================================
;; CURSOR POSITION — remember last place in files
;; ============================================================

;; Restore cursor to the last visited position when reopening files
(save-place-mode 1)


;; ============================================================
;; CUSTOM FILE — keep Emacs-generated settings out of init.el
;; ============================================================

;; Store customization variables in a separate file
(setq custom-file (locate-user-emacs-file "custom-vars.el"))

;; Load custom file quietly if it exists
(load custom-file 'noerror 'nomessage)


;; ============================================================
;; UI PROMPTS — disable graphical dialog boxes
;; ============================================================

;; Prefer minibuffer prompts over GUI dialog boxes
(setq use-dialog-box nil)


;; ============================================================
;; AUTO REVERT — refresh buffers when files change on disk
;; ============================================================

;; Automatically revert file buffers when the underlying file changes
(global-auto-revert-mode 1)

;; Also auto-revert non-file buffers (e.g. Dired)
(setq global-auto-revert-non-file-buffers t)
