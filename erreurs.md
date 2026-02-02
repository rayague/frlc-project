sbcl --noinform --load frlc-system/frlc.lisp --eval "(initialize-frlc)" --eval "(run-tests)" --quit

sbcl --load frlc-system/frlc.lisp --eval "(initialize-frlc)"

sbcl --noinform --eval "(load \"frlc-system/frlc.lisp\")" --eval "(initialize-frlc)" --eval "(Fcreate 'Objet 'Test)" --eval "(Fput 'Test 'nom 'value \"exemple\")" --eval "(format t \"Test: ~A~%\" (Fget 'Test 'nom 'value))" --quit

echo "(load \"frlc-system/frlc.lisp\") (initialize-frlc) (run-tests)" | sbcl --noinform

@echo off
sbcl --load frlc-system/frlc.lisp --eval "(initialize-frlc)" --eval "(format t \"FRLC chargé!~%%\")"

sbcl --load frlc-system/frlc.lisp --eval "(initialize-frlc)"