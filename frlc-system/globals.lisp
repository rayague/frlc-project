;;; globals.lisp -- variables globales et constantes
(in-package :frlc)

(defparameter *frames-table* (make-hash-table :test 'equal)
  "Table de hachage: nom-de-frame (symbole) -> frame-data (alist)")

(defparameter *frames* nil "Liste des noms de frames existants (symboles)")
(defparameter *demons* nil "Liste enregistrée des démons (symboles)")
(defparameter *variables* nil "Liste des variables système + utilisateur")
(defparameter *frame* nil "Frame courant (special var pour démons)")
(defparameter *slot* nil "Slot courant (special var pour démons)")
(defparameter *facet* nil "Facette courante (special var pour démons)")
(defparameter *value* nil "Valeur courante (special var pour démons)")

(defparameter *name-counter* 0 "Compteur pour la génération de noms de frames")
