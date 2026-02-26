;;; core-functions.lisp -- fonctions de base FRLC
(in-package :frlc)

 (declaim (ftype (function (t) list) Fslots))
 (declaim (ftype (function (t) list) inheritance-levels))

(defun Fgename ()
  "Genere un nom unique de frame (symbole)."
  (incf *name-counter*)
  (intern (format nil "FRLC-~A" *name-counter*) :cl-user))

(defun get-frame (name)
  "Retourne frame-data pour NAME ou nil."
  (when name
    (gethash name *frames-table*)))

(defun set-frame (name data)
  "Affecte DATA pour le frame NAME (dans la table) et enregistre le nom."
  (setf (gethash name *frames-table*) data)
  (pushnew name *frames* :test #'equal)
  data)

(defun Fgetframe (name)
  "Retourne la structure complete (alist) d'un frame."
  (get-frame name))

(defun ensure-frame (name)
  (or (get-frame name)
      (set-frame name (make-empty-frame))))

(defun find-slot-pair (frame-data slot)
  (and frame-data (alist-get slot frame-data)))

(defun find-facet-pair (slot-facets facet)
  (and slot-facets (assoc facet slot-facets :test #'equal)))

(defun add-value-to-facet! (slot-facets facet value)
  "Ajoute VALUE a FACET dans slot-facets in-place. Retourne T si ajoute, NIL si deja present."
  (let ((fac-pair (find-facet-pair slot-facets facet)))
    (if fac-pair
        (let ((vals (cdr fac-pair)))
          (if (find value vals :test #'equal)
              nil
              (progn (setf (cdr fac-pair) (cons value vals)) t)))
        (progn (push (cons facet (list value)) slot-facets) t))))

(defun remove-value-from-facet! (slot-facets facet value)
  "Supprime VALUE de FACET. Retourne T si supprime, NIL si absent."
  (let ((fac-pair (find-facet-pair slot-facets facet)))
    (when fac-pair
      (let ((new (remove value (cdr fac-pair) :test #'equal)))
        (setf (cdr fac-pair) new)
        t))))

(defun Fput (frame slot facet &optional value)
  "Place VALUE dans FRAME.SLOT.FACET sans declencher de demons.
Retourne NIL si la valeur existe deja, la valeur si ajout reussi."
  (when (null frame) (error "Fput: frame nil"))
  (let* ((f (ensure-frame frame))
         (slot-pair (find-slot-pair f slot)))
    ;; Create slot if it doesn't exist
    (unless slot-pair
      (setf slot-pair (cons slot nil))
      (push slot-pair f)
      (set-frame frame f))
    ;; Now add/modify the facet
    (let* ((slot-facets (cdr slot-pair))
           (fac-pair (find-facet-pair slot-facets facet)))
      (if fac-pair
          ;; Facet exists - check for duplicate and add if new
          (let ((vals (cdr fac-pair)))
            (if (find value vals :test #'equal)
                nil  ; already exists
                (progn
                  (setf (cdr fac-pair) (cons value vals))
                  (set-frame frame f)
                  value)))
          ;; Facet doesn't exist - create it
          (progn
            (setf (cdr slot-pair) (cons (cons facet (list value)) slot-facets))
            (set-frame frame f)
            value)))))

(defun Fget (frame slot facet)
  "Recupere la liste (potentiellement nil) des valeurs pour FRAME.SLOT.FACET"
  (let ((f (get-frame frame)))
    (when f
      (let ((slot-pair (find-slot-pair f slot)))
        (when slot-pair
          (let ((fac-pair (find-facet-pair (cdr slot-pair) facet)))
            (cdr fac-pair)))))))

(defun Fremove (frame slot facet value)
  "Supprime VALUE de FRAME.SLOT.FACET. Retourne T si supprime, NIL sinon."
  (let ((f (get-frame frame)))
    (when f
      (let ((slot-pair (find-slot-pair f slot)))
        (when slot-pair
          (let ((slot-facets (cdr slot-pair)))
            (when (remove-value-from-facet! slot-facets facet value)
              (set-frame frame f)
              t)))))))

(defun call-demons (frame slot event-facet &optional current-value)
  "Appelle les demons listes dans FRAME.SLOT.EVENT-FACET.
Chaque demon est une fonction (zero-arg) ou symbole fboundp.
Les variables speciales *frame* *slot* *facet* *value* sont bindees pendant l'appel.
Retourne la derniere valeur non-nil retournee par un demon (utile pour if-needed)."
  (let ((fns (Fget frame slot event-facet))
        (result nil))
    (when fns
      (dolist (fn (reverse fns) result)
        (let ((*frame* frame)
              (*slot* slot)
              (*facet* event-facet)
              (*value* current-value))
          (cond
            ((functionp fn) (let ((r (funcall fn))) (when r (setf result r))))
            ((and (symbolp fn) (fboundp fn)) (let ((r (funcall fn))) (when r (setf result r))))))))))

(defun Fput+ (frame slot facet &optional value)
  "Fput puis declenche les demons 'if-added' pour FRAME.SLOT.
Retourne la valeur si ajout, NIL si existait deja."
  (let ((r (Fput frame slot facet value)))
    (when r
      (call-demons frame slot 'if-added value))
    r))

(defun Fremove+ (frame slot facet value)
  "Fremove puis declenche les demons 'if-removed'. Retourne T si supprime."
  (let ((r (Fremove frame slot facet value)))
    (when r
      (call-demons frame slot 'if-removed value))
    r))

(defun Fcreate (parent name &optional (classification 'instance))
  "Cree un frame nommee NAME (symbole). Si NAME nil, genere un nom.
Parent peut etre nil, un symbole, ou une liste de symboles (heritage multiple).
La classification est 'instance ou 'prototype."
  (let ((n (or name (Fgename))))
    (unless (get-frame n)
      (set-frame n (make-empty-frame))
      (when parent
        (if (listp parent)
            ;; Iterate in reverse so push maintains left-to-right order
            (dolist (p (reverse parent)) (Fput n 'AKO 'value p))
            (Fput n 'AKO 'value parent)))
      (Fput n 'CLASSIFICATION 'value classification))
    n))

(defun Finst (parent &optional name)
  "Cree une instance (nom genere si name nil) avec parent.
Apres creation, declenche les demons 'if-needed' en breadth-first, left-to-right.
Retourne le nom de l'instance."
  (let ((instance (Fcreate parent name 'instance)))
    ;; BFS over ancestors to trigger if-needed for slots missing value
    (let ((levels (inheritance-levels instance)))
      (dolist (level levels)
        (dolist (ancestor level)
          (let ((slots (Fslots ancestor)))
            (dolist (s slots)
              (unless (Fget instance s 'value)
                ;; call if-needed demons on ancestor.s
                (let ((r (call-demons ancestor s 'if-needed)))
                  (when r
                    ;; if demon returns a value, set it on instance
                    (Fput+ instance s 'value r)))))))))
    instance))

;;; Fin core-functions.lisp
