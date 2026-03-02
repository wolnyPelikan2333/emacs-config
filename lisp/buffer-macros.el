;;; buffer-macros.el --- My window & buffer macros -*- lexical-binding: t; -*-

(defmacro bm:peek (&rest body)
  "Execute BODY temporarily and restore window configuration afterwards."
  `(let ((bm--window-state (current-window-configuration)))
     (unwind-protect
         (progn ,@body)
       (set-window-configuration bm--window-state))))

(defun bm/peek-command (command)
  "Run COMMAND with `bm:peek`.
COMMAND is any interactive command."
  (interactive
   (list
    (read-command "Peek command: ")))
  (bm:peek
    (call-interactively command)))

(provide 'buffer-macros)
;;; buffer-macros.el ends here
