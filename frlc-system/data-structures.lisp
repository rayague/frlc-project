;;; data-structures.lisp -- représentations internes
(in-package :frlc)

(defun make-empty-frame ()
  "Retourne la structure vide pour un frame : alist '((slot . facet-alist) ...)
facet-alist: alist of (facet . (values...))"
  nil)

(defun frame-slots (frame-data)
  "Retourne la liste des slots (symbols) d'un frame-data (alist)" 
  (mapcar #'car frame-data))

(defun slot-facets (slot-pair)
  "Retourne facet-alist pour une paire (slot . facet-alist)" 
  (cdr slot-pair))

(defun facet-values (facet-pair)
  "Retourne la liste de valeurs pour une paire (facet . values)" 
  (cdr facet-pair))
