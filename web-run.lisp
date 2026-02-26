;;; web-run.lisp -- demarrage du serveur Web FRLC
(load "frlc-system/frlc.lisp")
(in-package :frlc)

 (load "frlc-system/web.lisp")

(initialize-frlc)
(start-web-server :port 8080)

(loop (sleep 1))
