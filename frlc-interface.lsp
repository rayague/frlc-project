;;; frlc-interface.lsp -- Interface utilisateur (placeholders)

(defun Fmenu ()
  (format t "Fmenu placeholder. Implementer le menu interactif.~%"))

(defun Fwriteframe (frame)
  (format t "Frame ~A: ~S~%" frame (get-frame frame)))

;;; Fin frlc-interface.lsp
