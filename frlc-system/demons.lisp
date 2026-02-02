;;; demons.lisp -- gestion et utilitaires des démons
(in-package :frlc)

(defun register-demon (sym)
  "Enregistre un démon (symbole de fonction) dans *demons*." 
  (pushnew sym *demons* :test #'equal))

(defun Fako? (a b)
  "Teste si A est un descendant de B (AKO)." 
  (let ((anc (Fgetclasses a)))
    (find b anc :test #'equal)))

;;; Exemple de démon simple: log-change
(defun log-change ()
  "Démon d'exemple qui affiche le changement (utilise *frame* *slot* *value*)." 
  (format t "[demon] ~A: slot ~A changed -> ~S~%" *frame* *slot* *value*))

(register-demon 'log-change)

;;; Fin demons.lisp
