;;; frlc.lisp -- point d'entrée qui charge l'ensemble des modules
(load #P"frlc-system/package.lisp")
(in-package :frlc)

(mapc (lambda (f) (load (format nil "frlc-system/~A" f)))
      '("globals.lisp" "data-structures.lisp" "utilities.lisp"
        "core-functions.lisp" "inheritance.lisp" "demons.lisp"
        "interface.lisp" "persistence.lisp" "tribal-world.lisp"))

(defun initialize-frlc ()
  "Initialise le système FRLC: vide tables, créé Objet, initialise variables." 
  (clrhash *frames-table*)
  (setf *frames* nil *demons* nil *variables* nil)
  (let ((root (or (get-frame 'Objet) (set-frame 'Objet (make-empty-frame)))))
    (Fput 'Objet 'classification 'value 'prototype)
    (push 'Objet *frames*))
  (setf *variables* '(*frames* *demons* *variables* *frame* *slot* *facet* *value*))
  (format t "FRLC initialized. Root frame 'Objet' created.~%"))

;;; Fin frlc.lisp
