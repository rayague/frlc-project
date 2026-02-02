;;; persistence.lisp -- sauvegarde et chargement
(in-package :frlc)

(defun snapshot-frames-alist ()
  "Retourne une alist serializable de tous les frames: ((name . frame-data) ...)." 
  (let ((out '()))
    (maphash (lambda (k v) (push (cons k v) out)) *frames-table*)
    out)

(defun Fsave (filename)
  "Sérialise l'état des frames vers FILENAME." 
  (with-open-file (out filename :direction :output :if-exists :supersede :if-does-not-exist :create)
    (prin1 (snapshot-frames-alist) out)))

(defun Flood (filename)
  "Charge l'état des frames depuis FILENAME (remplace l'état courant)." 
  (with-open-file (in filename :direction :input)
    (let ((data (read in nil nil)))
      (clrhash *frames-table*)
      (setf *frames* nil)
      (dolist (pair data)
        (set-frame (car pair) (cdr pair))))))

;;; Fin persistence.lisp

)
