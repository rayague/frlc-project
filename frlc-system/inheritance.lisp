;;; inheritance.lisp -- gestion de l'héritage et recherches
(in-package :frlc)

(defun parents-of (frame)
  "Retourne la liste des parents (AKO.value) pour FRAME." 
  (or (Fget frame 'AKO 'value) '()))

(defun Fget-I (frame slot facet)
  "Recherche profondeur d'abord: FRAME puis parents (AKO) gauche->droite.
Retourne la première liste de valeurs trouvée (non-nil)." 
  (labels ((dfs (f visited)
             (when (and f (not (find f visited :test #'equal)))
               (let ((res (Fget f slot facet)))
                 (if res
                     res
                     (let ((ps (parents-of f)))
                       (dolist (p ps)
                         (let ((r (dfs p (cons f visited))))
                           (when r (return r)))))))))
    (dfs frame nil)))

(defun Fget-N (frame slot)
  "Recherche depth-first value -> defaut -> if-needed (profondeur).
Si if-needed donne une valeur, retourne cette valeur (et ne la met pas automatiquement)." 
  (or (Fget-I frame slot 'value)
      (Fget-I frame slot 'defaut)
      ;; if-needed: call demons and return their result
      (let ((res (Fget-I frame slot 'if-needed)))
        (when res
          ;; appeler les démons et renvoyer leur sortie (première non-nil)
          (let ((out nil))
            (dolist (d (reverse res) out)
              (let ((*frame* frame) (*slot* slot) (*facet* 'if-needed))
                (let ((r (cond ((functionp d) (funcall d))
                               ((and (symbolp d) (fboundp d)) (funcall d)))))
                  (when r (setf out r))))))))))

(defun Fget-Z (frame slot)
  "Recherche largeur d'abord; à chaque niveau: value, defaut, if-needed.
Retourne la première liste/valeur trouvée." 
  (let ((seen (list frame))
        (level (list frame)))
    (loop while level
          do (progn
               ;; search value in level
               (dolist (f level)
                 (let ((v (Fget f slot 'value)))
                   (when v (return v))))
               ;; search defaut
               (dolist (f level)
                 (let ((v (Fget f slot 'defaut)))
                   (when v (return v))))
               ;; search if-needed (call demons)
               (dolist (f level)
                 (let ((fns (Fget f slot 'if-needed)))
                   (when fns
                     (let ((res (call-demons f slot 'if-needed)))
                       (when res (return res))))))
               ;; build next level
               (let ((next '()))
                 (dolist (f level)
                   (dolist (p (parents-of f))
                     (unless (find p seen :test #'equal)
                       (push p next)
                       (push p seen))))
                 (setf level (nreverse next)))))))

(defun Fgetclasses (frame)
  "Liste des ascendants (AKO) sans doublon, profondeur-first order." 
  (let ((out '())
        (seen '()))
    (labels ((dfs (f)
               (dolist (p (parents-of f))
                 (unless (find p seen :test #'equal)
                   (push p out)
                   (push p seen)
                   (dfs p)))))
      (dfs frame)
      (nreverse out)))

(defun inheritance-levels (frame)
  "Retourne une liste de niveaux (listes) pour BFS: [[frame], [parents...], [parents-parents...]]" 
  (let ((seen (list frame))
        (current (list frame))
        (levels '()))
    (loop while current
          do (progn
               (push current levels)
               (let ((next '()))
                 (dolist (f current)
                   (dolist (p (parents-of f))
                     (unless (find p seen :test #'equal)
                       (push p next)
                       (push p seen))))
                 (setf current (nreverse next)))))
    (nreverse levels)))

;;; Fin inheritance.lisp

