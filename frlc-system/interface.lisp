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
    (maphash (lambda (k _v)
               (declare (ignore _v))
               (when (find parent (Fget k 'AKO 'value) :test #'equal)
                 (push k out))) *frames-table*)
    out))

(defun Fwriteframe (frame &optional stream)
  "Écrit la structure du FRAME sur STREAM (par défaut *standard-output*)." 
  (declare (ignore stream)) ; ignore stream for now, always return string
  (with-output-to-string (s)
    (pprint (get-frame frame) s)))

(defun Fmenu ()
  (format t "Fmenu: menu interactif non-implémenté (utiliser le REPL).~%"))

(defun Frame? (name)
  "Vérifie si NAME est un frame existant."
  (not (null (get-frame name))))

(defun Fname? (name)
  "Vérifie si NAME a un nom de frame valide."
  (and (symbolp name) (Frame? name)))

(defun Finstance? (frame)
  "Vérifie si FRAME est une instance."
  (equal (first (Fget frame 'CLASSIFICATION 'value)) 'instance))

(defun Fgeneric? (frame)
  "Vérifie si FRAME est un prototype."
  (equal (first (Fget frame 'CLASSIFICATION 'value)) 'prototype))

;;; Fin interface.lisp
