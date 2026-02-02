;;; frlc-core.lsp -- Noyau minimal FRLC (Common Lisp)
;; Chargement: (load "frlc-core.lsp")

(format t "Loading FRLC core...~%")

(defparameter *frames* nil "Liste des noms de frames existants")
(defparameter *demons* nil "Liste des demons enregistrés (non utilisé avancé)")
(defparameter *variables* nil "Variables globales système + utilisateur")
(defparameter *frame* nil "Frame courant")
(defparameter *slot* nil "Slot courant")
(defparameter *facet* nil "Facette courante")
(defparameter *value* nil "Valeur courante")

(defparameter *frame-table* (make-hash-table :test 'eq) "Map name -> frame-data")
(defparameter *name-counter* 0 "Compteur pour noms générés")

(defun Fgename ()
  "Génère un nouveau nom de frame unique (symbole)."
  (incf *name-counter*)
  (intern (format nil "FRLC-~A" *name-counter*)))

(defun get-frame (name)
  "Retourne la structure interne (alist) du frame NAME, ou nil." 
  (and name (gethash name *frame-table*)))

(defun set-frame (name data)
  "Assigne DATA au frame NAME et enregistre le nom dans *frames*."
  (setf (gethash name *frame-table*) data)
  (pushnew name *frames* :test 'eq)
  data)

(defun make-empty-frame ()
  "Structure interne: alist of (slot . facet-alist).
   facet-alist = alist of (facet . values-list)"
  nil)

(defun ensure-frame (name)
  (or (get-frame name)
      (set-frame name (make-empty-frame))))

(defun find-slot-pair (frame-data slot)
  "Retourne la paire (slot . facet-alist) ou nil." 
  (assoc slot frame-data))

(defun find-facet-pair (slot-facets facet)
  (and slot-facets (assoc facet slot-facets)))

(defun add-value-to-facet (slot-facets facet value)
  "Ajoute VALUE à la liste de la facette FACET dans slot-facets.
Retourne non-nil si ajouté." 
  (let ((fac-pair (find-facet-pair slot-facets facet)))
    (if fac-pair
        (unless (member value (cdr fac-pair) :test 'equal)
          (push value (cdr fac-pair))
          t)
        (progn
          (push (cons facet (list value)) slot-facets)
          t))))

(defun remove-value-from-facet (slot-facets facet value)
  (let ((fac-pair (find-facet-pair slot-facets facet)))
    (when fac-pair
      (let ((new (remove value (cdr fac-pair) :test 'equal)))
        (setf (cdr fac-pair) new)
        t))))

(defun Fput (frame slot facet value)
  "Place VALUE dans FACET du SLOT de FRAME (sans déclencher de démons).
Retourne VALUE si ajouté, nil si déjà présent." 
  (ensure-frame frame)
  (let ((fd (get-frame frame)))
    (let ((slot-pair (find-slot-pair fd slot)))
      (unless slot-pair
        (push (cons slot nil) fd)
        (set-frame frame fd)
        (setf slot-pair (find-slot-pair fd slot)))
      (let ((slot-facets (cdr slot-pair)))
        (when (add-value-to-facet slot-facets facet value)
          (set-frame frame fd)
          value)))))

(defun Fget (frame slot facet)
  "Récupère la liste des valeurs pour FRAME.SLOT.FACET ou nil." 
  (let ((fd (get-frame frame)))
    (when fd
      (let ((slot-pair (find-slot-pair fd slot)))
        (when slot-pair
          (let ((fac-pair (find-facet-pair (cdr slot-pair) facet)))
            (cdr fac-pair)))))))

(defun call-demons (frame slot event-facet)
  "Exécute les démons listés dans la facette EVENT-FACET pour FRAME.SLOT.
Les éléments peuvent être des fonctions ou des symbols définis (fboundp)."
  (let ((fns (Fget frame slot event-facet)))
    (when fns
      (dolist (fn fns)
        (cond
          ((functionp fn) (funcall fn))
          ((and (symbolp fn) (fboundp fn)) (funcall fn)))))))

(defun Fput+ (frame slot facet value)
  "Comme Fput puis déclenche les démons `if-added` pour ce slot." 
  (let ((r (Fput frame slot facet value)))
    (when r
      (call-demons frame slot 'if-added))
    r))

(defun Fremove (frame slot facet value)
  "Supprime VALUE de FRAME.SLOT.FACET. Retourne VALUE si supprimé." 
  (let ((fd (get-frame frame)))
    (when fd
      (let ((slot-pair (find-slot-pair fd slot)))
        (when slot-pair
          (let ((slot-facets (cdr slot-pair)))
            (when (remove-value-from-facet slot-facets facet value)
              (set-frame frame fd)
              value))))))

(defun Fremove+ (frame slot facet value)
  (let ((r (Fremove frame slot facet value)))
    (when r
      (call-demons frame slot 'if-removed))
    r))

(defun Fcreate (parent name)
  "Crée un frame nommé NAME (symbole). Si NAME nil, génère un nom.
Ajoute une entrée AKO -> parent (si parent non-nil)." 
  (let ((n (or name (Fgename))))
    (unless (get-frame n)
      (set-frame n (make-empty-frame))
      (when parent
        (Fput n 'AKO 'value parent))
      ;; classification: prototype/instance par défaut instance
      (Fput n 'CLASSIFICATION 'value 'instance))
    n))

;; Initialisation du frame racine Objet
(unless (get-frame 'Objet)
  (set-frame 'Objet (make-empty-frame))
  (format t "Created root frame Objet~%"))

;;; Fin frlc-core.lsp
