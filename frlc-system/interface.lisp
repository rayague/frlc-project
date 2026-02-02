;;; interface.lisp -- affichage et menu minimal
(in-package :frlc)

(defun Fslots (frame)
  "Retourne la liste des slots définis pour FRAME." 
  (let ((f (get-frame frame)))
    (when f (frame-slots f))))

(defun Ffacets (frame slot)
  "Retourne la liste des facettes pour FRAME.SLOT." 
  (let ((slot-pair (and (get-frame frame) (find-slot-pair (get-frame frame) slot))))
    (when slot-pair (mapcar #'car (cdr slot-pair)))))

(defun Fchildren (parent)
  "Liste des frames ayant PARENT dans leur AKO." 
  (let ((out '()))
    (maphash (lambda (k v)
               (when (find parent (Fget k 'AKO 'value) :test #'equal)
                 (push k out))) *frames-table*)
    out))

(defun Fwriteframe (frame &optional stream)
  "Écrit la structure du FRAME sur STREAM (par défaut *standard-output*)." 
  (with-output-to-string (s)
    (pprint (get-frame frame) s)))

(defun Fmenu ()
  (format t "Fmenu: menu interactif non-implémenté (utiliser le REPL).~%"))

;;; Fin interface.lisp
