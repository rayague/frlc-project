;;; tribal-world.lisp -- Monde Tribal complet
;;; Implementation du cas d'etude: gestion d'une tribu avec hommes et femmes

(in-package :frlc)

 (declaim (ftype (function () t) initialize-frlc))

;; ============================================================================
;; 1. INITIALISATION DU MONDE TRIBAL
;; ============================================================================

(defun setup-tribal ()
  "Initialise le Monde Tribal avec les prototypes Homme et Femme."
  (format t "~%=== Initialisation du Monde Tribal ===~%")
  
  ;; Creation de la hierarchie
  (Fcreate 'Objet 'Personne)
  (Fput 'Personne 'CLASSIFICATION 'value 'prototype)
  
  (Fcreate 'Personne 'Homme)
  (Fput 'Homme 'CLASSIFICATION 'value 'prototype)
  
  (Fcreate 'Personne 'Femme)
  (Fput 'Femme 'CLASSIFICATION 'value 'prototype)
  
  ;; Slots pour Homme : vivant, mere, femme, travail
  (Fput 'Homme 'vivant 'defaut t)
  (Fput 'Homme 'mere 'defaut nil)
  (Fput 'Homme 'femme 'defaut nil)  ; epouse
  (Fput 'Homme 'travail 'defaut nil)
  
  ;; Slots pour Femme : vivant, mere, femme, travail, enfants
  (Fput 'Femme 'vivant 'defaut t)
  (Fput 'Femme 'mere 'defaut nil)
  (Fput 'Femme 'femme 'defaut nil)  ; epouse
  (Fput 'Femme 'travail 'defaut 'elever-enfants)
  (Fput 'Femme 'enfants 'defaut '())
  (Fput 'Femme 'nb-enfants 'defaut 0)
  
  (format t "Prototypes crees: Personne, Homme, Femme~%")
  (format t "Slots Homme: vivant, mere, femme, travail~%")
  (format t "Slots Femme: vivant, mere, femme, travail, enfants, nb-enfants~%")
  (format t "=====================================~%~%"))

;; ============================================================================
;; 2. FONCTIONS DE VERIFICATION
;; ============================================================================

(defun personne-existe? (nom)
  "Verifie si une personne existe dans le monde tribal."
  (Frame? nom))

(defun personne-vivante? (nom)
  "Verifie si une personne est vivante."
  (and (personne-existe? nom)
       (equal (first (Fget-I nom 'vivant 'defaut)) t)))

(defun personne-mariee? (nom)
  "Verifie si une personne est mariee (a une femme/epouse)."
  (and (personne-existe? nom)
       (let ((epouse (first (Fget nom 'femme 'value))))
         (and epouse (not (equal epouse nil))))))

(defun get-epouse (nom)
  "Retourne l'epouse d'une personne, ou nil."
  (and (personne-existe? nom)
       (let ((ep (first (Fget nom 'femme 'value))))
         (if (and ep (not (equal ep nil))) ep nil))))

(defun get-mere (nom)
  "Retourne la mere d'une personne, ou nil."
  (and (personne-existe? nom)
       (let ((m (first (Fget nom 'mere 'value))))
         (if (and m (not (equal m nil))) m nil))))

(defun get-enfants (nom)
  "Retourne la liste des enfants d'une personne."
  (if (personne-existe? nom)
      (or (Fget nom 'enfants 'value) '())
      '()))

(defun nombre-enfants (nom)
  "Retourne le nombre d'enfants d'une personne."
  (length (get-enfants nom)))

(defun est-femme? (nom)
  "Verifie si la personne est une femme (instance de Femme)."
  (and (personne-existe? nom)
       (Fako? nom 'Femme)))

(defun est-homme? (nom)
  "Verifie si la personne est un homme (instance de Homme)."
  (and (personne-existe? nom)
       (Fako? nom 'Homme)))

;; ============================================================================
;; 3. FONCTION DE NAISSANCE
;; ============================================================================

(defun tribal-naissance (nom-mere nom-enfant)
  "Cree un nouvel enfant pour une mere.
Verifications:
- L'enfant n'existe pas deja
- La mere existe et est une femme
- La mere est mariee
- La mere n'est pas sa propre grand-mere
- La mere a moins de 10 enfants"
  
  (format t "~%[NAISSANCE] Demande: ~A veut avoir un enfant nomme ~A~%" nom-mere nom-enfant)
  
  ;; Verification 1: La mere existe
  (unless (personne-existe? nom-mere)
    (format t "ERREUR: La mere ~A n'existe pas.~%" nom-mere)
    (return-from tribal-naissance nil))
  
  ;; Verification 2: La mere est une femme
  (unless (est-femme? nom-mere)
    (format t "ERREUR: ~A n'est pas une femme (impossible d'avoir un enfant).~%" nom-mere)
    (return-from tribal-naissance nil))
  
  ;; Verification 3: L'enfant n'existe pas deja
  (when (personne-existe? nom-enfant)
    (format t "ERREUR: L'enfant ~A existe deja.~%" nom-enfant)
    (return-from tribal-naissance nil))
  
  ;; Verification 4: La mere est mariee
  (unless (personne-mariee? nom-mere)
    (format t "ERREUR: ~A n'est pas mariee (enfant interdit hors mariage).~%" nom-mere)
    (return-from tribal-naissance nil))
  
  ;; Verification 5: La mere est vivante
  (unless (personne-vivante? nom-mere)
    (format t "ERREUR: ~A n'est pas vivante.~%" nom-mere)
    (return-from tribal-naissance nil))
  
  ;; Verification 6: La mere n'est pas sa propre grand-mere
  (let ((mere-de-la-mere (get-mere nom-mere)))
    (when (and mere-de-la-mere (equal mere-de-la-mere nom-enfant))
      (format t "ERREUR: ~A ne peut pas etre sa propre grand-mere.~%" nom-mere)
      (return-from tribal-naissance nil)))
  
  ;; Verification 7: Moins de 10 enfants
  (when (>= (nombre-enfants nom-mere) 10)
    (format t "ERREUR: ~A a deja 10 enfants (limite atteinte).~%" nom-mere)
    (return-from tribal-naissance nil))
  
  ;; Creation de l'enfant
  (let ((pere (get-epouse nom-mere)))
    ;; Determiner le sexe de l'enfant (alternance ou aleatoire simple)
    (let* ((nb-enfants-actuel (nombre-enfants nom-mere))
           (nouveau-sexe (if (evenp nb-enfants-actuel) 'Homme 'Femme))
           (nouveau-genre (if (equal nouveau-sexe 'Homme) "un garcon" "une fille")))
      
      ;; Creer l'enfant
      (Fcreate nouveau-sexe nom-enfant)
      (Fput nom-enfant 'CLASSIFICATION 'value 'instance)
      (Fput nom-enfant 'mere 'value nom-mere)
      (Fput nom-enfant 'vivant 'value t)
      
      ;; Si c'est une fille, initialiser ses slots specifiques
      (when (equal nouveau-sexe 'Femme)
        (Fput nom-enfant 'enfants 'value '())
        (Fput nom-enfant 'nb-enfants 'value 0))
      
      ;; Ajouter l'enfant a la liste des enfants de la mere
      (let ((liste-enfants (get-enfants nom-mere)))
        (Fput nom-mere 'enfants 'value (cons nom-enfant liste-enfants))
        (Fput nom-mere 'nb-enfants 'value (1+ (length liste-enfants))))
      
      ;; Message de confirmation
      (format t "SUCCES: ~A a donne naissance a ~A (~A).~%" nom-mere nom-enfant nouveau-genre)
      (format t "        Pere: ~A, Mere: ~A~%" pere nom-mere)
      (format t "        Total enfants de ~A: ~A~%" nom-mere (1+ nb-enfants-actuel))
      
      ;; Retourner l'enfant cree
      nom-enfant)))

;; ============================================================================
;; 4. FONCTION DE MARIAGE
;; ============================================================================

(defun tribal-mariage (nom-homme nom-femme)
  "Marie un homme et une femme.
Verifications:
- Ils ne sont pas deja maries
- Ils sont tous les deux vivants
- L'homme est bien un homme
- La femme est bien une femme"
  
  (format t "~%[MARIAGE] Demande: ~A et ~A veulent se marier~%" nom-homme nom-femme)
  
  ;; Verification 1: Les deux personnes existent
  (unless (personne-existe? nom-homme)
    (format t "ERREUR: ~A n'existe pas.~%" nom-homme)
    (return-from tribal-mariage nil))
  
  (unless (personne-existe? nom-femme)
    (format t "ERREUR: ~A n'existe pas.~%" nom-femme)
    (return-from tribal-mariage nil))
  
  ;; Verification 2: L'homme est bien un homme
  (unless (est-homme? nom-homme)
    (format t "ERREUR: ~A n'est pas un homme.~%" nom-homme)
    (return-from tribal-mariage nil))
  
  ;; Verification 3: La femme est bien une femme
  (unless (est-femme? nom-femme)
    (format t "ERREUR: ~A n'est pas une femme.~%" nom-femme)
    (return-from tribal-mariage nil))
  
  ;; Verification 4: Ils ne sont pas deja maries
  (when (personne-mariee? nom-homme)
    (format t "ERREUR: ~A est deja marie (epouse: ~A).~%" 
            nom-homme (get-epouse nom-homme))
    (return-from tribal-mariage nil))
  
  (when (personne-mariee? nom-femme)
    (format t "ERREUR: ~A est deja mariee (epoux: ~A).~%"
            nom-femme (get-epouse nom-femme))
    (return-from tribal-mariage nil))
  
  ;; Verification 5: Ils sont vivants
  (unless (personne-vivante? nom-homme)
    (format t "ERREUR: ~A n'est pas vivant.~%" nom-homme)
    (return-from tribal-mariage nil))
  
  (unless (personne-vivante? nom-femme)
    (format t "ERREUR: ~A n'est pas vivante.~%" nom-femme)
    (return-from tribal-mariage nil))
  
  ;; Mariage: creation du lien reciproque
  (Fput nom-homme 'femme 'value nom-femme)
  (Fput nom-femme 'femme 'value nom-homme)
  
  (format t "SUCCES: ~A et ~A sont maintenant maries.~%" nom-homme nom-femme)
  t)

;; ============================================================================
;; 5. GESTION DU TRAVAIL
;; ============================================================================

(defun tribal-apprendre-metier (nom-homme metier)
  "Apprend un metier a un homme.
Seuls les hommes peuvent apprendre un metier."
  
  (format t "~%[APPRENTISSAGE] ~A veut apprendre le metier: ~A~%" nom-homme metier)
  
  ;; Verification 1: La personne existe
  (unless (personne-existe? nom-homme)
    (format t "ERREUR: ~A n'existe pas.~%" nom-homme)
    (return-from tribal-apprendre-metier nil))
  
  ;; Verification 2: C'est un homme
  (unless (est-homme? nom-homme)
    (format t "ERREUR: ~A n'est pas un homme. Seuls les hommes peuvent apprendre un metier.~%" nom-homme)
    (return-from tribal-apprendre-metier nil))
  
  ;; Verification 3: Il est vivant
  (unless (personne-vivante? nom-homme)
    (format t "ERREUR: ~A n'est pas vivant.~%" nom-homme)
    (return-from tribal-apprendre-metier nil))
  
  ;; Apprendre le metier
  (Fput nom-homme 'travail 'value metier)
  (format t "SUCCES: ~A a appris le metier de ~A.~%" nom-homme metier)
  t)

(defun tribal-travailler (nom-personne)
  "Demande a une personne de travailler.
- Si c'est un homme: affiche son travail
- Si c'est une femme mariee: fait naitre un enfant
- Sinon: erreur"
  
  (format t "~%[TRAVAIL] ~A est appele(e) au travail~%" nom-personne)
  
  ;; Verification 1: La personne existe
  (unless (personne-existe? nom-personne)
    (format t "ERREUR: ~A n'existe pas.~%" nom-personne)
    (return-from tribal-travailler nil))
  
  ;; Verification 2: La personne est vivante
  (unless (personne-vivante? nom-personne)
    (format t "ERREUR: ~A n'est pas vivant(e).~%" nom-personne)
    (return-from tribal-travailler nil))
  
  ;; Cas 1: C'est un homme
  (when (est-homme? nom-personne)
    (let ((metier (first (Fget nom-personne 'travail 'value))))
      (if (and metier (not (equal metier nil)))
          (progn
            (format t "~A exerce son metier: ~A~%" nom-personne metier)
            (format t "        (Action: ~A en action!)~%" metier)
            metier)
          (format t "~A n'a pas appris de metier particulier.~%" nom-personne))))
  
  ;; Cas 2: C'est une femme
  (when (est-femme? nom-personne)
    ;; Si elle est mariee, elle peut avoir un enfant (c'est son travail)
    (if (personne-mariee? nom-personne)
        (let* ((prenoms-enfants '("Enfant1" "Enfant2" "Enfant3" "Enfant4" "Enfant5"
                                  "Enfant6" "Enfant7" "Enfant8" "Enfant9" "Enfant10"))
               (nb-enfants (nombre-enfants nom-personne))
               (nouveau-prenom (nth nb-enfants prenoms-enfants)))
          (if (< nb-enfants 10)
              (progn
                (format t "~A (femme) effectue son travail: elever les enfants~%" nom-personne)
                (format t "        Nouvelle grossesse detectee...~%")
                (tribal-naissance nom-personne (or nouveau-prenom (intern (format nil "Enfant~A" (1+ nb-enfants))))))
              (format t "~A a deja 10 enfants, elle ne peut plus en avoir.~%" nom-personne)))
        (format t "~A n'est pas mariee, son travail est d'attendre le mariage.~%" nom-personne))))

;; ============================================================================
;; 6. DEMONSTRATION COMPLETE
;; ============================================================================

(defun run-tribal-demo ()
  "Execute une demonstration complete du Monde Tribal."
  (format t "~%##############################################~%")
  (format t "### DEMONSTRATION DU MONDE TRIBAL COMPLET ###~%")
  (format t "##############################################~%")
  
  ;; Initialisation
  (initialize-frlc)
  (setup-tribal)
  
  ;; Creation d'individus
  (format t "~%--- Creation des individus ---~%")
  (Fcreate 'Homme 'Jean)
  (Fput 'Jean 'vivant 'value t)
  (format t "Cree: Jean (Homme, vivant)~%")
  
  (Fcreate 'Homme 'Pierre)
  (Fput 'Pierre 'vivant 'value t)
  (format t "Cree: Pierre (Homme, vivant)~%")
  
  (Fcreate 'Femme 'Marie)
  (Fput 'Marie 'vivant 'value t)
  (format t "Cree: Marie (Femme, vivante)~%")
  
  (Fcreate 'Femme 'Julie)
  (Fput 'Julie 'vivant 'value t)
  (format t "Cree: Julie (Femme, vivante)~%")
  
  ;; Tentative de mariage
  (format t "~%--- Tentatives de mariage ---~%")
  (tribal-mariage 'Jean 'Marie)  ; Devrait reussir
  (tribal-mariage 'Pierre 'Julie)  ; Devrait reussir
  (tribal-mariage 'Jean 'Julie)  ; Devrait echouer (Jean deja marie)
  
  ;; Apprentissage des metiers
  (format t "~%--- Apprentissage des metiers ---~%")
  (tribal-apprendre-metier 'Jean 'forgeron)
  (tribal-apprendre-metier 'Pierre 'chasseur)
  (tribal-apprendre-metier 'Marie 'couturiere)  ; Devrait echouer (c'est une femme)
  
  ;; Travail des hommes
  (format t "~%--- Travail des hommes ---~%")
  (tribal-travailler 'Jean)
  (tribal-travailler 'Pierre)
  
  ;; Naissances (via le travail des femmes ou directement)
  (format t "~%--- Naissances ---~%")
  (tribal-naissance 'Marie 'PetitJean)  ; Devrait reussir
  (tribal-naissance 'Marie 'PetiteMarie)  ; Devrait reussir
  (tribal-naissance 'Julie 'PetitPierre)  ; Devrait reussir
  
  ;; Tentative erronee: mere non mariee
  (format t "~%--- Test de securite: femme non mariee ---~%")
  (let ((celibataire (Fcreate 'Femme 'Celibataire)))
    (declare (ignore celibataire))
    (Fput 'Celibataire 'vivant 'value t)
    (tribal-naissance 'Celibataire 'EnfantIllegitime))  ; Devrait echouer
  
  ;; Tentative erronee: mere inexistante
  (format t "~%--- Test de securite: mere inexistante ---~%")
  (tribal-naissance 'Inconnue 'EnfantOrphelin)  ; Devrait echouer
  
  ;; Travail des femmes (declenche naissances si mariees)
  (format t "~%--- Travail des femmes ---~%")
  (tribal-travailler 'Marie)  ; Devrait faire naitre un enfant
  (tribal-travailler 'Julie)  ; Devrait faire naitre un enfant
  
  ;; Resume final
  (format t "~%--- Resume de la tribu ---~%")
  (format t "Frames crees: ~A~%" (Fgetframes))
  (format t "Enfants de Marie: ~A~%" (get-enfants 'Marie))
  (format t "Enfants de Julie: ~A~%" (get-enfants 'Julie))
  (format t "~%##############################################~%")
  (format t "### FIN DE LA DEMONSTRATION ###~%")
  (format t "##############################################~%~%"))

;; ============================================================================
;; Fin tribal-world.lisp
;; ============================================================================
