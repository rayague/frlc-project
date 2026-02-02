;;; tests.lisp -- tests de validation Phase1
(in-package :frlc)

(defun run-tests ()
  (format t "Running FRLC Phase1 tests...~%")
  (initialize-frlc)

  ;; Test 1: Création de base
  (Fcreate 'Objet 'Personne)
  (Fput 'Personne 'nom 'value "defaut")
  (assert (equal (Fget 'Personne 'nom 'value) '("defaut")))
  (format t "✓ Test1: creation de base OK~%")

  ;; Test 2: Héritage simple
  (Fcreate 'Personne 'Homme)
  (Fput 'Homme 'sexe 'value "masculin")
  (Fput 'Homme 'age 'defaut 30)
  (Fcreate 'Homme 'jean)
  (assert (equal (Fget-I 'jean 'sexe 'value) '("masculin")))
  (assert (equal (Fget-I 'jean 'age 'defaut) '(30)))
  (format t "✓ Test2: heritage simple OK~%")

  ;; Test 3: démons
  (defun calcul-salaire ()
    1000)
  (register-demon 'calcul-salaire)
  (Fput 'Personne 'salaire 'if-needed 'calcul-salaire)
  (Fput 'Homme 'age 'if-added 'log-change)
  (Fput+ 'jean 'age 'value 25)
  ;; log-change should have printed; ensure value set
  (assert (equal (Fget 'jean 'age 'value) '(25)))
  (format t "✓ Test3: demons OK~%")

  ;; Test 4: Fget-N should trigger calcul-salaire and return 1000
  (let ((res (Fget-N 'jean 'salaire)))
    (assert (= res 1000)))
  (format t "✓ Test4: Fget-N OK~%")

  (format t "All tests passed.~%"))

;;; Fin tests.lisp
