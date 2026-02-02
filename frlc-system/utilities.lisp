;;; utilities.lisp -- fonctions utilitaires
(in-package :frlc)

(defun ensure-symbol (x)
  "Assure que X est un symbole; si string, intern." 
  (cond ((symbolp x) x)
        ((stringp x) (intern (string-upcase x) :cl-user))
        (t x)))

(defun alist-get (key alist)
  "Associe like lookup using equal on keys" 
  (assoc key alist :test #'equal))

(defun alist-put! (alist key value)
  "Remplace la valeur pour KEY dans ALIST in-place (renvoie ALIST modifié)." 
  (let ((pair (alist-get key alist)))
    (if pair
        (setf (cdr pair) value)
        (push (cons key value) alist))
    alist)

(defun list-unique (lst &key (test #'equal))
  "Retourne une nouvelle liste avec éléments uniques en gardant l'ordre." 
  (let ((out nil))
    (dolist (x lst (nreverse out))
      (unless (find x out :test test)
        (push x out)))))
