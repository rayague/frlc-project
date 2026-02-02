;;; tribal-world.lisp -- Monde Tribal: modèles et démons métiers
(in-package :frlc)

(defun setup-tribal ()
  "Initialise les prototypes Homme/Femme et quelques démons métier." 
  (Fcreate 'Objet 'Personne 'prototype)
  (Fcreate 'Personne 'Homme 'prototype)
  (Fcreate 'Personne 'Femme 'prototype)
  ;; defaults
  (Fput 'Homme 'vivant 'defaut t)
  (Fput 'Femme 'vivant 'defaut t)
  (Fput 'Personne 'enfants 'value '())
  ;; démon de naissance (simplifié)
  (defun demon-birth ()
    (format t "[demon] naissance triggered for ~A slot ~A~%" *frame* *slot*))
  (register-demon 'demon-birth)
  (format t "Monde Tribal initialisé.~%"))

(defun tribal-create-child (mother child-name)
  "Démon/méthode simplifiée pour simuler la naissance d'un enfant." 
  (let ((*frame* mother) (*slot* 'enfants))
    (let ((children (or (Fget mother 'enfants 'value) '())))
      (when (>= (length children) 10)
        (error "Mother ~A already has 10 children" mother))
      (when (find child-name children :test #'equal)
        (error "Child ~A already exists" child-name))
      (push child-name children)
      (Fput+ mother 'enfants 'value child-name)
      (format t "Child ~A born for mother ~A~%" child-name mother))))

;;; Fin tribal-world.lisp
