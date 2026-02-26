;;; interface.lisp -- affichage et fonctions d'interface
(in-package :frlc)

 (defun Frame? (name)
  "Verifie si NAME est un frame existant."
  (not (null (get-frame name))))

 (defun Fname? (name)
  "Verifie si NAME a un nom de frame valide et existe."
  (and (symbolp name) (Frame? name) name))

 (defun Finstance? (frame)
  "Verifie si FRAME est une instance."
  (equal (first (Fget frame 'CLASSIFICATION 'value)) 'instance))

 (defun Fgeneric? (frame)
  "Verifie si FRAME est un prototype."
  (equal (first (Fget frame 'CLASSIFICATION 'value)) 'prototype))

 (defun Fwriteframe (frame &optional stream)
  "Ecrit la structure du FRAME sur STREAM (par defaut *standard-output*)."
  (declare (ignore stream))
  (with-output-to-string (s)
    (pprint (get-frame frame) s)))

(defun Fslots (frame)
  "Retourne la liste des slots definis pour FRAME."
  (let ((f (get-frame frame)))
    (when f (mapcar #'car f))))

(defun Ffacets (frame slot)
  "Retourne la liste des facettes pour FRAME.SLOT."
  (let ((slot-pair (and (get-frame frame) (find-slot-pair (get-frame frame) slot))))
    (when slot-pair (mapcar #'car (cdr slot-pair)))))

(defun Fchildren (parent)
  "Liste des frames ayant PARENT dans leur AKO."
  (let ((out '()))
    (maphash (lambda (k _v)
               (declare (ignore _v))
               (when (find parent (Fget k 'AKO 'value) :test #'equal)
                 (push k out))) *frames-table*)
    out))

(defun Fgetframes ()
  "Retourne la liste de tous les noms de frames existants."
  (copy-list *frames*))

(defun Fname (frame)
  "Retourne le nom du frame si celui-ci existe, nil sinon."
  (when (get-frame frame) frame))

(defun Fnames? (name)
  "Verifie si NAME est un nom de frame valide et existant."
  (and (symbolp name) (Frame? name) name))

(defun Flink? (frame1 slot frame2)
  "Verifie si FRAME2 est lie a FRAME1 par le SLOT.
Exemple: (Flink? 'jean 'ako 'homme) verifie si jean est un homme."
  (when (and (Frame? frame1) (Frame? frame2))
    (let ((links (Fget frame1 slot 'value)))
      (find frame2 links :test #'equal))))

(defun Fcheck (frame slot facet constraint-fn)
  "Verifie que la valeur de FRAME.SLOT.FACET satisfait la fonction de contrainte.
CONSTRAINT-FN est une fonction qui prend la valeur et retourne T si valide.
Retourne T si valide, nil sinon."
  (let ((value (Fget frame slot facet)))
    (and value (funcall constraint-fn value))))

(defun Fimprim (filename &optional (frames-list nil))
  "Ecrit les frames dans un fichier texte de maniere lisible.
Si FRAMES-LIST est nil, exporte tous les frames."
  (with-open-file (out filename :direction :output :if-exists :supersede :if-does-not-exist :create)
    (format out "=== FRLC Frames Export ===~%~%")
    (let ((frames-to-export (or frames-list (Fgetframes))))
      (dolist (f frames-to-export)
        (when (Frame? f)
          (format out "Frame: ~A~%" f)
          (format out "Structure: ~S~%~%" (Fgetframe f)))))
    (format out "=== End of Export ===~%"))
  filename)

(defun Fmenu-display-choices (choices title)
  "Affiche un menu avec numérotation."
  (format t "~%~A~%" title)
  (format t "~A~%" (make-string (length title) :initial-element #\=))
  (loop for i from 1
        for choice in choices
        do (format t "  ~D. ~A~%" i choice))
  (format t "  0. Quitter~%~%"))

(defun Fmenu-read-choice (max)
  "Lit un choix valide de l'utilisateur."
  (loop
    (format t "Choix (0-~D): " max)
    (finish-output)
    (let* ((input (read-line))
           (num (parse-integer input :junk-allowed t)))
      (when (and num (>= num 0) (<= num max))
        (return num)))
    (format t "Choix invalide.~%")))

(defun Fmenu-create-frame ()
  "Sous-menu pour creer un frame."
  (format t "\n=== Creation d'un frame ===~%")
  (format t "Nom du frame: ")
  (finish-output)
  (let ((name (read)))
    (format t "Parent (symbole ou liste): ")
    (finish-output)
    (let ((parent (read)))
      (format t "Type (1=prototype, 2=instance): ")
      (finish-output)
      (let ((type-choice (parse-integer (read-line))))
        (let ((result (Fcreate parent name (if (= type-choice 1) 'prototype 'instance))))
          (format t "Frame ~A cree.~%" result))))))

(defun Fmenu-modify-frame ()
  "Sous-menu pour modifier un frame."
  (format t "\n=== Modification d'un frame ===~%")
  (format t "Nom du frame: ")
  (finish-output)
  (let ((frame (read)))
    (unless (Frame? frame)
      (format t "Frame ~A inexistant.~%" frame)
      (return-from Fmenu-modify-frame))
    (format t "Slot: ")
    (finish-output)
    (let ((slot (read)))
      (format t "Facette (value/defaut/if-added/if-removed/if-needed): ")
      (finish-output)
      (let ((facet (read)))
        (format t "Valeur: ")
        (finish-output)
        (let ((value (read)))
          (Fput frame slot facet value)
          (format t "Valeur ~A positionnee dans ~A.~A.~A~%" value frame slot facet))))))

(defun Fmenu-display-frame ()
  "Sous-menu pour afficher un frame."
  (format t "\n=== Affichage d'un frame ===~%")
  (format t "Nom du frame: ")
  (finish-output)
  (let ((frame (read)))
    (if (Frame? frame)
        (format t "~A~%" (Fwriteframe frame))
        (format t "Frame ~A inexistant.~%" frame))))

(defun Fmenu-list-frames ()
  "Affiche la liste de tous les frames."
  (format t "\n=== Liste des frames ===~%")
  (let ((frames (Fgetframes)))
    (if frames
        (loop for f in frames
              for i from 1
              do (format t "  ~D. ~A (~A)~%" i f 
                         (if (Finstance? f) "instance" "prototype")))
        (format t "  Aucun frame.~%"))))

(defun Fmenu-search-inheritance ()
  "Sous-menu pour recherche avec heritage."
  (format t "\n=== Recherche avec heritage ===~%")
  (format t "Frame de depart: ")
  (finish-output)
  (let ((frame (read)))
    (unless (Frame? frame)
      (format t "Frame inexistant.~%")
      (return-from Fmenu-search-inheritance))
    (format t "Slot a chercher: ")
    (finish-output)
    (let ((slot (read)))
      (format t "Type de recherche:~%")
      (format t "  1. Fget-I (profondeur d'abord)~%")
      (format t "  2. Fget-N (value->defaut->if-needed)~%")
      (format t "  3. Fget-Z (largeur d'abord)~%")
      (format t "Choix: ")
      (finish-output)
      (let ((choice (parse-integer (read-line) :junk-allowed t)))
        (let ((result (case choice
                      (1 (Fget-I frame slot 'value))
                      (2 (Fget-N frame slot))
                      (3 (Fget-Z frame slot))
                      (otherwise nil))))
          (format t "Resultat: ~A~%" result))))))

(defun Fmenu ()
  "Menu interactif principal pour FRLC."
  (format t "~%=== FRLC - Menu Principal ===~%~%")
  (let ((running t))
    (loop while running do
      (Fmenu-display-choices 
        '("Creer un frame" 
          "Modifier un frame"
          "Afficher un frame"
          "Lister tous les frames"
          "Recherche avec heritage"
          "Executer les tests"
          "Sauvegarder (Fsave)"
          "Charger (Fload)")
        "Menu Principal")
      (let ((choice (Fmenu-read-choice 8)))
        (case choice
          (0 (setf running nil)
             (format t "Au revoir.~%"))
          (1 (Fmenu-create-frame))
          (2 (Fmenu-modify-frame))
          (3 (Fmenu-display-frame))
          (4 (Fmenu-list-frames))
          (5 (Fmenu-search-inheritance))
          (6 (let ((sym 'run-tests))
               (if (fboundp sym)
                   (funcall (symbol-function sym))
                   (format t "Tests non disponibles (charger frlc-system/tests.lisp).~%"))))
          (7 (progn
               (format t "Nom du fichier: ")
               (finish-output)
               (Fsave (read-line))
               (format t "Sauvegarde effectuee.~%")))
          (8 (progn
               (format t "Nom du fichier: ")
               (finish-output)
               (Flood (read-line))
               (format t "Chargement effectue.~%"))))))))

;;; Fin interface.lisp
