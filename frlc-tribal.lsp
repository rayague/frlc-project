;;; frlc-tribal.lsp -- Monde Tribal (exemples)
;; Exemple minimal: création de prototypes Homme/Femme
(load "frlc-core.lsp")

(defun setup-tribal ()
  (Fcreate 'Objet 'Personne)
  (Fcreate 'Personne 'Homme)
  (Fcreate 'Personne 'Femme)
  ;; valeurs par défaut
  (Fput 'Homme 'vivant 'defaut 'true)
  (Fput 'Femme 'vivant 'defaut 'true)
  (format t "Monde Tribal initialisé.~%"))

;;; Fin frlc-tribal.lsp
