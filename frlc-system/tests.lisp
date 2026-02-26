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

  (initialize-frlc)
  (Fcreate 'Objet 'A)
  (Fcreate 'Objet 'B)
  (Fput 'A 'x 'defaut 1)
  (Fput 'B 'x 'defaut 2)
  (Fcreate (list 'A 'B) 'C)
  (assert (equal (Fget-I 'C 'x 'defaut) '(1)))
  (format t "✓ Test5: heritage multiple OK~%")

  (initialize-frlc)
  (Fcreate 'Objet 'CycleA)
  (Fcreate 'CycleA 'CycleB)
  (Fput 'CycleA 'AKO 'value 'CycleB)
  (Fput 'CycleB 'y 'defaut 42)
  (assert (equal (Fget-I 'CycleA 'y 'defaut) '(42)))
  (format t "✓ Test6: cycle AKO OK~%")

  (initialize-frlc)
  (Fcreate 'Objet 'PersistParent)
  (Fcreate 'PersistParent 'PersistChild)
  (Fput 'PersistParent 'p 'defaut "ok")
  (Fput 'PersistChild 'c 'value 123)
  (let ((tmp "frlc-test-save.dat"))
    (ignore-errors (delete-file tmp))
    (Fsave tmp)
    (initialize-frlc)
    (Flood tmp)
    (assert (equal (Fget-I 'PersistChild 'p 'defaut) '("ok")))
    (assert (equal (Fget 'PersistChild 'c 'value) '(123)))
    (ignore-errors (delete-file tmp)))
  (format t "✓ Test7: persistence OK~%")

  (format t "All tests passed.~%"))

;;; Fin tests.lisp
