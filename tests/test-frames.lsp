;;; tests/test-frames.lsp -- tests unitaires minimaux
(load "../frlc-core.lsp")

(defun test-fput-fget ()
  (let ((n (Fcreate 'Objet 'Toto)))
    (Fput n 'nom 'value "Toto")
    (assert (equal (Fget n 'nom 'value) '("Toto")))
    (format t "✓ test-fput-fget ok~%")))

(test-fput-fget)
