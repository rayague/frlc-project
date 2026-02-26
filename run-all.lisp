;;; run-all.lisp -- script pour charger FRLC et executer les tests
(load "frlc-system/frlc.lisp")
(in-package :frlc)
(initialize-frlc)
(load "frlc-system/tests.lisp")
(run-tests)
(format t "~%=== FRLC Tests Completed ===~%")
